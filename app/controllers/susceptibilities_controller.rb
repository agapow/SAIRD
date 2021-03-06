class SusceptibilitiesController < ApplicationController

	hobo_model_controller

	auto_actions :all

	def index
			# filter list so people can't see anything but their own countries
		
		if current_user.administrator?
			hobo_index
		else
			if current_user.guest?
				country_ids = [-1]
			else
				country_ids = current_user.user_countries.collect { |u| u.country_id }
			end
			hobo_index(Susceptibility.scoped(:conditions=>{:country_id=>country_ids}))
		end
	end

#  autocomplete_for :title

	
end
