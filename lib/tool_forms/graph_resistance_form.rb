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
			return "Show whiskerbox and scatter plots of resistance data. These
				will show the susceptibility entries for a given country, season
				and pathogen type, compared to the thresholds for that season if
				available."
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
			
			pp errors
			
			# TODO: check users are allowed to see country
			
			search_msg = "Searching for #{cntry}, #{ssn.year}, #{pthgn_typ}, #{rstnc.agent} ..."
			
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
			season_thresholds = (0 < t_entries.length) ? t_entries[0] : nil
			pp "The season thresholds are: #{season_thresholds}"
			if season_thresholds.nil?
				threshold_msg = "No threshold can be found for this country / season / resistance combination"
			else
				threshold_msg = "The season thresholds are #{season_thresholds[0]}, #{season_thresholds[1]}."
			end
			
			# generate graphs
			graphs_locn = "graphs"
			graphs_dir = "#{RAILS_ROOT}/public/#{graphs_locn}/"
			graphs_url = "#{ENV.fetch("RAILS_RELATIVE_URL_ROOT", '')}/#{graphs_locn}/"
			base_plot_name = generate_plot_basename()
			pp "the filepath is #{base_plot_name} which is on the path #{graphs_dir} and the url #{graphs_url}"
			
			# generate whisker graph
			pltr = Plotting::WhiskerPlotter.new(:legend => false)
			data = filtered_reports.collect { |d| d[1] }
			svg = pltr.render_data([['Reports', data]], :thresholds => season_thresholds)
				
			whisker_svg_path = "#{graphs_dir}#{base_plot_name}-whisker.svg"
			pp whisker_svg_path
			outfile = open(whisker_svg_path, 'w')
			outfile.write (svg)
			outfile.close()
			
			whisker_png_path = "#{graphs_dir}#{base_plot_name}-whisker.png"
			system ("rsvg #{whisker_svg_path} #{whisker_png_path}")
			whisker_png_url = "#{graphs_url}#{base_plot_name}-whisker.png"
			
			img_msg = "<img src='#{whisker_png_url}'>"
			
			# generate scatter plot
			pltr = Plotting::ScatterByDatePlotter.new(:legend => false)
			data = filtered_reports.collect { |d| [d[0], d[1]] }
			svg = pltr.render_data([['Reports', data]], :thresholds => season_thresholds)
			
			scatterdate_svg_path = "#{graphs_dir}#{base_plot_name}-scatterdate.svg"
			pp scatterdate_svg_path
			outfile = open(scatterdate_svg_path, 'w')
			outfile.write (svg)
			outfile.close()
			
			scatterdate_png_path = "#{graphs_dir}#{base_plot_name}-scatterdate.png"
			system ("rsvg #{scatterdate_svg_path} #{scatterdate_png_path}")
			scatterdate_png_url = "#{graphs_url}#{base_plot_name}-scatterdate.png"
			
			simg_msg = "<img src='#{scatterdate_png_url}'>"
			
			## Return:
			return [
				search_msg,
				"#{filtered_reports.length()} matching records were found.",
				threshold_msg,
				img_msg,
				simg_msg
			], []
			
		end
		
		
		def self.generate_plot_basename()
			return (0...8).map{ ('a'..'z').to_a[rand(26)] }.join
		end
		
	end

end


### END
