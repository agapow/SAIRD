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
   
   # Who is allowed to view the country?
   #
   # Currently, we let everyone who is a member of any country see the country.
   # Anonymous and unverified users are forbidden. 
   #
   # TODO: customise this for different fields?
   #
   def read_permitted?
   	if acting_user.guest? or (acting_user.countries.length() == 0)
   		return false
   	end
      return true
   end
   
   # Who is allowed to edit resistance data?
   #
   def write_permitted?
      return acting_user.administrator?
   end

	## Accessors:
	def name
		return "#{agent} #{unit}".strip()
	end
	
end
