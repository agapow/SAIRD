class NewsItem < ActiveRecord::Base

   hobo_model # Don't put anything above this

   # add in shared behaviour
   include ExtendedModelMixin
   
   ## Db model & relationships:
   fields do
      name        :string, :required
      body        :markdown, :required
      
      timestamps
   end

   belongs_to :poster, :class_name => "User", :creator => true
   
   set_default_order "updated_at DESC"


   ## Permissions:
   # can only be created & edited by admins, but everyone can view it.
   def read_permitted?
      true
   end
   
   def write_permitted?
      acting_user.administrator?
   end
   
	def poster_view_permitted?
		true
	end

end
