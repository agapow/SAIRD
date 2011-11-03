class Resistance < ActiveRecord::Base

	hobo_model # Don't put anything above this
	
   # add in shared behaviour
   include ExtendedModelMixin
   
	## Db model & relationships:
	fields do
		agent        :string, :required, :unique
		description :text
		unit        :text
	
		timestamps
	end
	
	set_default_order :agent

	## Validations:
	def clean_name(v)
		return v.strip()
	end	
	
	def clean_description(v)
		return v.strip()
	end	
	
	def clean_unit(v)
		return v.strip()
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

	## Accessors:
	def name
		return "#{agent} #{unit}".strip()
	end
	
end
