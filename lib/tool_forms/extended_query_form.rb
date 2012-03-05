#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

# Tool for more complicated queries.

### IMPORTS


### IMPLEMENTATION

module ToolForms
	
	# A tool to handle complicated queries
	class ExtendedQueryForm < BaseToolForm
		
		## Accessors:
		@@submit_buttons = ['Query']
				
		def self.description
			# TODO: sucky description
			return 'Search the database for suceptibility entries.'
		end
		
		def self.id
			return "exquery"
		end
		
		def self.submit_buttons
			return [['query', 'Query']]
		end
		
		
		#def self.validate_virustype(param_str)
		#	vt = VirusType.find(id=param_str.to_i)
		#	return vt
		#	validate(false, "this is another error!")
		#end
		
		
		def self.is_valid?(params)
			# gets many seasons, many countries, many pathogens
			# these can be one, none or many
			
			pp "**** params #{params}"
			clean_params = {}
			errors = []
				
			[:season, :pathogen_type, :country].each { |p|
				param_name = p.to_s
				param_list = params[param_name].nil? ? [] : params[param_name]
				pp param_list
				clean_params[p] = param_list.collect { |x|
					x.to_i
				}
			}
			
			pp "**** clean params #{clean_params}"
			
			return clean_params, errors
		end
		
		
		## Services:
		
		# Return all resistance reports for this season & virus type & country
		# 
		# Returns results, errors
		#
		def self.process_default(params)
			# TODO: allow multiple seaons & virus types? Ordering?
			pp params
			
			# build conditions
			conditions = {}
			conditions[:season_id] =  params[:season]
			conditions[:country_id] =  params[:country]
			conditions[:pathogen_type_id] =  params[:pathogen_type]
			
			# retrieve matching records
			reports = Susceptibility.scoped(:conditions => conditions).all()
			pp "the results"
			pp reports
			
			# if no matching, return no result answer
			if reports.empty?
				return [], []
			else
				# here we just return ids, other the session gets overly full
				return reports.collect { |r| r.id }, []
			end
		end
		
	end

end


### END
