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
			## Preconditions & preparation:
			pp params
			
			cntry = Country.find_by_id(params[:country])
			ssn = Season.find_by_id(params[:season])
			pthgn_typ = PathogenType.find_by_id(params[:pathogen_type])
			rstnc = Resistance.find_by_id(params[:resistance])

				errors = []
			if cntry.nil?
				errors << "No such country"
			end
			if ssn.nil?
				errors << "No such season"
			end
			if pthgn_typ.nil?
				errors << "No such pathogen"
			end
			if rstnc.nil?
				errors << "No such resistance"
			end
			
			if (0 < errors.length())
				return [], errors
			end
			
			# TODO: check users are allowed to see country
			
			search_msg = "Searching for #{cntry}, #{ssn}, #{pthgn_typ}, #{rstnc}"
			
			## Main:
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
			filtered_reports = []
			reports.each { |r|
				r.susceptibility_entries.each { |e|
					if e.resistance_id == params[:resistance]
						filtered_reports << [r.collected, e.measure]
					end
				}
			}
			
			pp "THESE ARE THE FILTERED SUSC ENTRIES"
			pp filtered_reports
			
			# if no matching, return no result answer
			if filtered_reports.empty?
				return [], ["No results were returned. Perhaps you should widen the search parameters"]
			end

			# if too few to graph, return message
			if (filtered_reports.length() < 8)
				return [], ["Too few results to graph (#{filtered_reports.length()}). Perhaps you should widen the search parameters"]
			end
			
			# get threshold if available
			# should by one at most
			thresholds = Threshold.scoped(:conditions => conditions).all()
			t_entries = []
			thresholds.each { |t|
				t.thresholdentries.each { |e|
					if e.resistance_id == params[:resistance]
						t_entries << [e.minor, e.major]
					end
				}
			}
			season_thresholds = (0 < t_netries.length) ? t_entries[0] : nil
			pp "The season thresholds are: #{season_thresholds}"
			
			# generate box graph
			base_file_path = generate_filepath_to_plot()
			pp "the filepath is #{base_file_path}"
			
			# generate scatter plot
			
			
			return [search_msg, "#{filtered_reports.length()} matching records were found."], []
			
		end
		
		def generate_random_filename()
			return (0...8).map{ ('a'..'z').to_a[rand(26)] }.join
		end
		
		def self.generate_filepath_to_plot()
			basename = (0...8).map{ ('a'..'z').to_a[rand(26)] }.join
			return "#{RAILS_ROOT}/public/graphs/#{basename}"
		end
		
	end

end


### END
