#
# monkey patch math to add a conversion to radians
#
module Math
	def self.to_rad angle
		angle/180 * Math::PI
	end
end