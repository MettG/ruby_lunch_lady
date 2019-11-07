require "pry"
require "colorize"

class Menu
	puts
end
class User
	private
		class Wallet
			attr_accessor :amount
			def initialize(dollars)
				@amount = dollars
			end
			def deduct(val)
				@amount -= val
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
end
class Dish

end

class MainDish < Dish

end

class SideDish < Dish

end

class LunchLady

end