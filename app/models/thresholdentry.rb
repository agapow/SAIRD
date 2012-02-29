
# The minor and major thresholds for a given drug.
#
# This is given in the context of a threshold, which is for a given season,
# country and virus.
#
class Thresholdentry < ActiveRecord::Base

	hobo_model # Don't put anything above this
	
   # add in shared behaviour
   include ExtendedModelMixin
   
	## Fields & relationships:
	fields do
		minor :float
		major :float

		timestamps
	end

	belongs_to :threshold
	belongs_to :resistance

	## Validations:
	validates_presence_of :resistance_id
	validates_numericality_of :minor, :greater_than_or_equal_to => 0.0 
	validates_numericality_of :major, :greater_than_or_equal_to => 0.0 

	def validate
		if self ['major'] <= self['minor']
			errors.add('minor', 'minor cutoff must be less than major')
		end
	end

	## Accessors:
	def name
		return "%s (%s-%s%s)" % [
			resistance.nil? ? '-' : resistance.name,
			minor.nil? ? '-' : minor,
			major.nil? ? '-' : major,
			resistance.nil? ? '' : resistance.unit,
		]
	end


	## Permissions:
	def create_permitted?
		true
	end

	def update_permitted?
		true
	end

	def destroy_permitted?
		true
	end

	def view_permitted?(field)
		true
	end

end
