
# A region and implied authority for that region
#
# In SAIRD, data is gathered per country and user access is restricted as per
# the countries they "belong" to.
#
class Country < ActiveRecord::Base

   hobo_model # Don't put anything above this
   
   # add in shared behaviour
   include ExtendedModelMixin
   
   ## Fields & relationships:
   fields do
      # brazil    :string # :name => true
      # you put :name => true if you want a drop down list in the belongs_to
      # (e.g. here susceptibility belong_to country).
      name  :string, :required, :unique
      
      timestamps
   end
   
   has_many :users, :through => :user_countries, :accessible => true
   has_many :user_countries, :dependent => :destroy
 
   set_default_order :name
  
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
   
   # Who is allowed to edit country data?
   #
   def write_permitted?
      return acting_user.administrator?
   end
   
end
