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
			results_arr = []
			results_arr << "Searching for #{cntry}, #{ssn.year}, #{pthgn_typ}, #{rstnc.agent} ..."
			
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
			else
				results_arr << "#{filtered_reports.length()} matching records were found."
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
			# generate basic vars for graphs
			graphs_locn = "graphs"
			graphs_dir = "#{RAILS_ROOT}/public/#{graphs_locn}/"
			graphs_url = "/#{graphs_locn}/"
			base_plot_name = generate_plot_basename()
			
			# generate the data
			w_bottom, p25, p50, p75, w_top = Plotting::whisker_and_box_bounds(
				filtered_reports.collect { |d| d[1] },
				:log => true
			)
			pp "our box and whisker is #{w_bottom}, #{p25}, #{p50}, #{p75}, #{w_top}"
			iqr = p75 - p25
			extrap_thresholds = [p75 + (1.5 * iqr), p75 + (3.0 * iqr)]
			pp "extrap thresholds = #{extrap_thresholds}"
			
			outliers = []
			inliers = []
			filtered_reports.each { |d|
				if ((d[1] < w_bottom) or (w_top < d[1]))
					outliers << d
				else
					inliers << d
				end
			}
			pp "SPLIT DATA"
			pp outliers
			pp inliers
			
			
			
			# generate whisker graphs
			# first graph, no outliers, second outliers
			plot_args = [
				{
					:title => 'Reported resistance distribution',
					:name => 'whisker',
					:log => false,
					:outliers => []
				},
				{
					:title => 'Reported resistance distribution, with outliers',
					:name => 'whisker-outliers',
					:log => true,
					:outliers => outliers.collect { |d| d[1] }
				},
			]
						
			plot_args.each { |a|
				
				pltr = Plotting::WhiskerPlotter.new(:legend => false, :log => a[:log])
				svg = pltr.render_data([['Reports', [w_bottom, p25, p50, p75, w_top]]],
					:season_thresholds => season_thresholds,
					:extrapolated_thresholds => extrap_thresholds,
					:outliers => a[:outliers],
				)
					
				svg_path = "#{graphs_dir}#{base_plot_name}-#{a[:name]}.svg"
				outfile = open(svg_path, 'w')
				outfile.write (svg)
				outfile.close()
				
				png_path = svg_path.gsub(/\.svg$/, '.png')
				system ("rsvg #{svg_path} #{png_path}")
				png_url = "#{graphs_url}#{base_plot_name}-#{a[:name]}.png"
				results_arr << ImageResult.new(png_url, :caption => a[:title])
			}
			
			
			# generate scatter plot
			scatter_date_args = [
				{
					:title => 'Reported resistance versus date',
					:name => 'scatter-date',
					:log => false,
					:outliers => []
				},
				{
					:title => 'Reported resistance versus date, with outliers',
					:name => 'scatter-date-outliers',
					:log => true,
					:outliers => outliers
				},
			]

			scatter_date_args.each { |a|
				
				pltr = Plotting::ScatterByDatePlotter.new(:legend => false, :log => a[:log])
				svg = pltr.render_data([['', inliers]],
					:season_thresholds => season_thresholds,
					:extrapolated_thresholds => extrap_thresholds,
					:outliers => a[:outliers],
				)
				
				svg_path = "#{graphs_dir}#{base_plot_name}-#{a[:name]}.svg"
				pp svg_path
				outfile = open(svg_path, 'w')
				outfile.write (svg)
				outfile.close()
				
				png_path = svg_path.gsub(/\.svg$/, '.png')
				system ("rsvg #{svg_path} #{png_path}")
				png_url = "#{graphs_url}#{base_plot_name}-#{a[:name]}.png"
				results_arr << ImageResult.new(png_url, :caption => a[:title])

			}
			
			## Return:
			return results_arr, []
			
		end
		
		
		def self.generate_plot_basename()
			return (0...8).map{ ('a'..'z').to_a[rand(26)] }.join
		end
		
	end

end


### END
