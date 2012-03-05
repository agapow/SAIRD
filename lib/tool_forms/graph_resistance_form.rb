#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

# Tool for graphing susceptibility data.

### IMPORTS


### IMPLEMENTATION

module ToolForms

	class GraphResistanceForm < BaseToolForm
		# TODO: we need a lot better description about this sucker
		
		@@submit_buttons = ['Graph']
		
		def self.title
			return 'Graph resistance data'
		end
		
		def self.submit_buttons
			return [['graph', 'Graph']]
		end
		
		def self.description
			return """Produce box and scatter plots of resistance data."""
		end
		
		def self.id
			return 'graphresist'
		end
		
		
		def self.is_valid?(params)
			# gets a season, a country, a pathogen, a resistance
			# these must be one of each
			
			pp "**** params #{params}"
			clean_params = {}
			errors = []
				
			[:season, :pathogen_type, :country, :resistance].each { |p|
				param_name = p.to_s
				if params[param_name].nil?
					errors << "need an entry for #{param_name}"
				else
					clean_params[p] = params[param_name].to_i
				end
			}
			
			pp "**** clean params #{clean_params}"
			
			return clean_params, errors
		end
		
		
		## Services:
		
		# Return the box and scatter plots for the selected records
		#
		# Returns results, errors
		#
		def self.process_default(params)
			pp params
			
			# build conditions
			conditions = {}

			conditions[:season_id] =  params[:season]
			conditions[:country_id] =  params[:country]
			conditions[:pathogen_type_id] =  params[:pathogen_type]

			
			# retreive matching records
			reports = Susceptibility.scoped(:conditions => conditions).all()
			pp "the results"
			pp reports
			
			# now filter for suceptibiities_entrui
			sus_entries = []
			reports.each { |r|
				sus_entries.concat (r.susceptibility_entries)
			}
			
			pp "THESE ARE THE SUSC ENTRIES"
			pp sus_entries
			
			# now filter entries
			filtered_reports = sus_entries.select { |s|
				s.resistance_id == params[:resistance]
			}
			
			# if no matching, return no result answer
			if filtered_reports.empty?
				return [], ["No results were returned. Perhaps you should widen the search parameters"], []
			end

			# if too few to graph, return message
			if (filtered_reports.length() < 8)
				return [], ["Too few results to graph (#{filtered_reports.length()}). Perhaps you should widen the search parameters"], []
			end
			
			# gather values
			vals = filtered_reports.collect { |fr| fr.measure }.sort()
			val_count = vals.length()
			# find box bounds
			i25, i50, i75 = (val_count * 0.25).ceil(), (val_count * 0.50).round(), (val_count * 0.75).floor()
			p25, p50, p75 = vals[i25-1], vals[i50-1], vals[i75-1]
			# find whisker bounds
			iqr = p75 - p25
			w_top = p75 + (1.5 * iqr)
			w_top_val = vals.select { |v| v <= w_top }.max
			w_bottom = p25 - (1.5 * iqr)
			w_botom_val = vals.select { |v| w_bottom <= v }.min
			
			# generate box graph
			
			
			# generate scatter plot
			
			
			return ["#{filtered_reports.length()} matching records were found."], []
			
		end
		
		
		
	end

end


### END
