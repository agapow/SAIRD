#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

# Tool for more complicated queries.

### IMPORTS


### IMPLEMENTATION

module ToolForms
	
	# A tool to handle complicated queries
	class ExtendedQueryToolForm < BaseToolForm
		
		## Accessors:
		@@submit_buttons = ['Query']
				
		def self.description
			# TODO: sucky description
			return 'Search the database for suceptibility reports.'
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
			pp "**** params #{params}"
			clean_params = {}
			errors = []
				
			[:season, :pathogen_type, :country, :resistance].each { |p|
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
		def self.process_default(params)
			# TODO: allow multiple seaons & virus types? Ordering?
			pp params
			
			# build conditions
			conditions = {}
			if ! params[:season].empty?
				conditions[:season_id] =  params[:season]
			end
			if ! params[:country].empty?
				conditions[:country_id] =  params[:country]
			end
			if ! params[:pathogen_type].empty?
				conditions[:pathogen_type_id] =  params[:pathogen_type]
			end
			
			# retreive matching records
			reports = Susceptibility.scoped(:conditions => conditions).all()
			pp "the results"
			pp reports
			
			if ! params[:resistance].empty?
				
				
				
			end
			
			
			# if no matching, return no result answer
			if reports.empty?
				return ["No results were returned. Perhaps you should widen the
					search parameters"], []
			else
				return reports, []
			end
		end
		
	end

end


### END
