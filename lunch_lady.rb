require "pry"
require "colorize"

class Menu
	attr_reader :main_dishes, :side_dishes, :user
	def initialize(dishes, user)
		@main_dishes = []
		@side_dishes = []
		@user = user
		dishes.each do |d|
			if d.class.name == MainDish
				@main_dishes.push(d)
			else
				@side_dishes.push(d)
			end
		end
	end
	def select 
		puts "1) View Current Order".green
		puts "2) Order new item".green
		puts "3) Exit".green
		case gets.to_i
			when 1
				@user.view
			when 2
				select_dish
			when 3
				exit
			else
				puts "Invalid choice!".red
		end
		select
	end
	def select_dish
		puts "1) View main dishes".green
		puts "2) View side dishes".green
		case gets.to_i
			when 1
				select_main
			when 2
				select_side
			else
				puts "Invalid choice!".red
				select_dish
		end
	end
	def select_main
		i = 0
		@main_dishes.each do |d|
			i+=1
			print "#{i}) "
			puts d.view
		end
		puts "Select item to get more info, or any other key to return.".green
		i = gets.to_i
		if i < @main_dishes.length
			@main_dishes[i].detail
			puts "Press 'a' to add to order, any other key to look at the items again.".green
			if gets.strip == "a"
				@user.add_main(@main_dishes[i])
			end
		end
	end
	def select_side
		i = 0
		@side_dishes.each do |d|
			i+=1
			print "#{i}) "
			puts d.view
		end
		puts "Select item to get more info, or any other key to return.".green
		i = gets.to_i
		if i < @side_dishes.length
			@side_dishes[i].detail
			puts "Press 'a' to add to order, any other key to look at the other sides.".green
			if gets.strip == "a"
				@user.add_main(@side_dishes[i])
				puts "Add another side? (y/n)"
				if gets.strip == "y"
					select_side
				end
			else
				select_side
			end
		end
	end
end
class User
	attr_accessor :wallet, :orders
	def initialize(dollars)
		@wallet = Wallet.new(dollars)
		@orders = Order.new
	end
	def add_main(dish)
		unless @orders.has_main
			@orders.add_main(dish)
		else
			print "You already have a main dish, replace it? (Y/N) > ".yellow
			case gets.strip
				when "Y", "y"
					clear_main
					@orders.add_main(dish)
					return
				when "N", "n"
					return
			else
				puts "Invalid choice. Try Again.".red
				add_main(dish)
			end
		end
	end
	def add_side(dish)
		@orders.add_side(dish)
	end
	def clear_sides
		@orders.clear_sides
	end
	def clear_all
		@orders.clear
	end
	def clear_main
		@orders.clear_main
	end
	def view
		@orders.view
	end
	private
		class Wallet
			attr_accessor :amount
			def initialize(dollars)
				@amount = dollars
			end
			def deduct(val)
				@amount -= val
			end
			def refund(val)
				@amount += val
			end
			def purchase(val)
				if @amount >= val
					deduct(val)
					true
				else
					false
				end
			end
		end
		class Order
			attr_accessor :dishes, :total, :calories
			def initialize
				@dishes = { main: nil, sides: []}
				@total = 0
				@calories = 0
			end
			def add_main(dish)
				unless @wallet.purchase(dish.cost)
					puts "Cannot add item, not enough money!".red
					return
				end
				@dishes[:main] = dish
				@wallet.purchase(dish.cost)
				@total += dish.cost
				@calories += dish.cal
			end
			def has_main
				return @dishes[:main] != nil
			end
			def add_side(dish)
				unless @wallet.purchase(dish.cost)
					puts "Cannot add item, not enough money!".red
					return
				end
				@dishes[:side].push(dish)
				@total += dish.cost
				@calories += dish.cal
			end
			def view(fin=false)
				if @total == 0
					puts "No items on order!".red
					return
				end
				if fin
					puts "-- Final Order --".red
				else
					puts "-- Current Order --".green
				end
				puts "Main Dish".magenta
				puts "#{@dishes.main.name}".colorize(:green) + " " + 
						 "#{@dishes.main.cal}".colorize(:blue) + " -" + 
						 "#{@dishes.main.cost}".colorize(:red)
				puts " "
				puts "Side Dishes".magenta
				@dishes.sides.each do |d|
					puts "#{d.name}".colorize(:green) + " " + 
						   "#{d.cal}".colorize(:blue) + " -" + 
						 	 "#{d.cost}".colorize(:red)
				end
				puts " "
				puts "Total Calories: #{@calories} Total Cost: #{@total}".colorize(:white, :background => :blue)
			end
			def clear_sides
				@dishes.sides.each do |d|
					@total -= d.cost
					@calories -= d.cal
					@wallet.refund(d.cost)
				end
				@dishes.sides = []
			end
			def clear_main
				@wallet.refund(@dishes.main.cost)
				@total -= @dishes.main.cost
				@calories -= @dishes.main.cal
				@dishes.main = nil
			end
			def clear
				@wallet.refund(@total)
				@total = 0
				@calories = 0
				@dishes = {main: nil, sides: []}
			end
		end
end
class Dish
	attr_accessor :name, :cost, :cal, :descrip
	def initialize(name,cost,cal,descrip)
		@name = name
		@cost = cost
		@cal = cal
		@descrip = descrip
	end
	def view
		puts "#{@name}".cyan
	end
	def detail
		view
		puts "#{@descrip}".cyan
		puts "Calories: #{@cal} Cost: -#{@cost}".red
	end
end

class MainDish < Dish
	def initialize(n,cost,cal,d)
		super(n,cost,cal,d)
	end
end

class SideDish < Dish
	def initialize(n,cost,cal,d)
		super(n,cost,cal,d)
	end
end

class LunchLady
	Dishes = [
		MainDish.new("Steak",25,1000,"Juicy Tenderloin, cooked to your liking."),
		MainDish.new("Seared Chicken",18,500,"Tender chicken breast, seared on the grill."),
		MainDish.new("Noodles",5,420,"Bowl of packaged noodles, affordable."),
		MainDish.new("Mountain Man Dinner",32,1800,"A meal man enough for two men. Hamburger meat, chicken, potatoes, and carrots."),
		SideDish.new("Fries",2,400,"Browned to perfection, sprinkled with salt."),
		SideDish.new("Bowl of Broccoli",5,200,"Steamed or raw."),
		SideDish.new("Baked Potato",3.50,310,"Baked with onions for some reason."),
		SideDish.new("Kiddie rings",2,100,"A childish take on onion rings, for those trying to cut down on fried food."),
		SideDish.new("Bacon Critters",10,1000,"A heap of chopped pork sausages wrapped with bacon and onion, deep-fried."),
		SideDish.new("Whatchma-callit",1.5,180,"Not actually sure what this is, but it tastes amazing!")
	]
	def initialize
		puts "--Welcome to the Lunch Lady--".yellow
		puts "How much money did you bring with you?".green
		money = 0
		while true
			money = gets.to_i
			if money <= 0
				puts "That's not a valid amount.".red
				next
			else
				break
			end
		end
		Menu.new(Dishes,money)
	end
end

LunchLady.new