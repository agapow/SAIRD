class SusceptibilitiesController < ApplicationController

  hobo_model_controller

  auto_actions :all
 
  
  
	def index
		if current_user.administrator?
			hobo_index
		else
			if current_user.guest?
				country_ids = [100]
			else
				country_ids = current_user.user_countries.collect { |u| u.country_id }
			end
			hobo_index(Susceptibility.scoped(:conditions=>{:country_id=>country_ids}))
		end
	end

#  autocomplete_for :title

#def show
#  hobo_show :permission_denied_response => proc { 
#	render :text => "On yer bike sunshine!"
#  }, :not_found_response => proc {
#	redirect_to homepage_url
#  } 
#end 
end
