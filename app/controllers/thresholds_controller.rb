class ThresholdsController < ApplicationController

  hobo_model_controller

  auto_actions :all

	def index
		if current_user.administrator?
			hobo_index
		else
			if current_user.guest?
				country_ids = [-1]
			else
				country_ids = current_user.user_countries.collect { |u| u.country_id }
			end
			hobo_index(Threshold.scoped(:conditions=>{:country_id=>country_ids}))
		end
	end
	
	#	def show
	#		if current_user.guest?
	#			hobo_show({
	#				:permission_denied_response => proc { render :text => "On yer bike sunshine!" },
	#				:not_found_response => proc { redirect_to homepage_url }
	#			})
	#		else
	#			hobo_show
	#		end
	#	end

end
