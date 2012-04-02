#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

### END
#
module Plotting
   
	# Renders data as a scatter plot where ponts are [date, val]
	# 
	# Oddly enough, rubyvis can only handle Times not dates, so you have to pass Time structures
	#
	class ScatterByDatePlotter  < BasePlotter
	   
	   attr_accessor(
	      :data_series,  # [[name, [[x1, y1], ], ...]
	      :plot_wt,
	      :plot_ht,
	      :canvas_wt,
	      :canvas_ht,
	      :margin,
	      :title,
	      :log,
	   )
	   
	   def initialize(kwargs={})
	      ## Preconditions:
	      opts = OpenStruct.new({
	         :plot_ht => 250,
	         :plot_wt => 400,
	         :legend => true,
	         :log => false,
	      }.merge(kwargs))
	      ## Main:
	      @plot_ht = opts.plot_ht
	      @plot_wt = opts.plot_wt
	      @canvas_ht = opts.plot_ht
	      @canvas_wt = opts.plot_wt
	      @legend = opts.legend
	      @log = opts.log
	   end
	   
	   # Create a plot of the passed data and return as an SVG.
	   #
	   # @param [] data   an array of datasets, being [name, [data]]
	   #   where data is a series of date, value pairs
	   #
	   def render_data(data, kwargs={})
	      ## Preconditions:
	      opts = OpenStruct.new({
	         :season_thresholds => nil,
	         :extrapolated_thresholds => nil,
	         :outliers => [],
	      }.merge(kwargs))   
	
	      ## Main:
	      epoch = Date.new(1970,1,1)
	      @data_series = data.collect { |r|
	         row_title = r[0]
	         row_data = r[1].collect { |p|
	            [(p[0] - epoch).to_i, p[1]]
	         }
	         [row_title, row_data]
      	}
	      
	      # NOTE: need index to seperate colors
	      @data_series.each_with_index { |d, i| d << i }
	      	pp @data_series
	      
	      # find limits of data so we know where axes are
	      x_data = @data_series.collect { |series|
	         series[1].collect { |pt|
	            pt[0]
	         }
	      }.flatten()
	      if ! opts.outliers.nil?
				opts.outliers = opts.outliers.collect { |p|
					[(p[0] - epoch).to_i, p[1]]
				}
	      	x_data.concat(opts.outliers.collect { |x| x[0] })
			end
	      x_min, x_max = x_data.min(), x_data.max()
	      x_bounds = bounds([x_min, x_max])
	
	      y_data = @data_series.collect { |series|
	         series[1].collect { |pt|
	            pt[1]
	         }
	      }.flatten()
			if ! opts.outliers.nil?
				x_data.concat(opts.outliers.collect { |x| x[1] })
			end
	      y_min, y_max = y_data.min(), y_data.max()
	      possible_range = [y_min, y_max]
	      if ! opts.season_thresholds.nil?
	         possible_range.concat (opts.season_thresholds)
	      end
			if ! opts.extrapolated_thresholds.nil?
			   possible_range.concat (opts.extrapolated_thresholds)
			end
	      y_bounds = bounds(possible_range)
	      
	      # make area for plotting
	      # ???: adhoc values for left, etc. set padding for labels
	      vis = pv.Panel.new()
	         .width(@canvas_wt)
	         .height(@canvas_ht)
	         .left(75)
	         .bottom(20)
	         .top(10)
	         .right(75)
	      
	      # scaling to position datapoints in plot
	      horiz = pv.Scale.linear(x_bounds[0], x_bounds[1]).nice().range(0, @plot_wt)
	      
	      if @log
	      	vert = pv.Scale.log(y_bounds[0]+0.01, y_bounds[1]).nice().range(0, @plot_ht)
	      else
	      	vert = pv.Scale.linear(y_bounds[0], y_bounds[1]).nice().range(0, @plot_ht)
			end

	      # without this, errors out with Date.to_f missing method
	      format = pv.Format.date("%b")
	      c = pv.Scale.linear(0, @data_series.size()-1).range("red", "blue")
	      
	      # do the axes
	      # TODO: change text to be (epoch + d).strftime("%m/%d")
	      horiz_label_ticks = horiz.ticks.each_slice(3).map(&:first)
	      vis.add(pv.Rule)
	         .data(horiz.ticks())
	         .left(horiz)
	         .stroke_style("#eee")
	         .add(pv.Label)
	            .bottom(0)
	            .text_margin(10)
					.text(lambda {|d| (epoch + d).strftime("%m/%d")})
	            .textBaseline("top")
	            .textAlign("center")
	            .visible(lambda {|d| horiz_label_ticks.member?(d)})
	      
	      vert_label_ticks = vert.ticks.each_slice(4).map(&:first)
	      vis.add(pv.Rule)
	         .data(vert.ticks())
	         .bottom(vert)
	         .stroke_style(lambda {|d| d!= vert.ticks()[0] ? "#eee" : "#000"})
	         .add(pv.Label)
	            .left(0)
	            .text_margin(5)
	            .text(lambda {|d| "%.1f" % d})
	            .textBaseline("top")
	            .textAlign("right")
	            .visible(lambda {|d| vert_label_ticks.member?(d)})
	            #.margin(5)
	            #.text(lambda {|d| vert_label_ticks.member?(d) ? sprintf("%0.2f", d) : ''})
	
	      # rubyvis refuses to produce tick at beginning of x-axis
	      # y (vertical) axis
	      vis.add(pv.Rule)
	         .data([0])
	         .left(0)
	         .bottom(@margin)
	         .strokeStyle("black")
	         
	         
	      # TODO: chnage stroke and fill styles to allow for
	      # multiple data sets
	      @data_series.each_with_index { |series, i|
	         vis.add(pv.Dot)
	            .data(series[1])
	            .left(lambda {|d| horiz.scale(d[0])})
	            .bottom(lambda {|d| vert.scale(d[1])})
	            .stroke_style("blue")
	            .fill_style("grey")
	            .shape_size(3)       
	      }
			if ! opts.outliers.empty?
	        vis.add(pv.Dot)
	            .data(opts.outliers)
	            .left(lambda {|d| horiz.scale(d[0])})
	            .bottom(lambda {|d| vert.scale(d[1])})
	            .stroke_style("red")
	            .fill_style("grey")
	            .shape_size(3)
			end

			threshold_data = [
				{
					:title => 'user-defined',
					:data => opts.season_thresholds.nil? ? [] : opts.season_thresholds,
					:colour => "red",
				},
				{
					:title => 'calculated',
					:data => opts.extrapolated_thresholds.nil? ? [] : opts.extrapolated_thresholds,
					:colour => 'orange',
				}
			]
			
			threshold_data.each { |t|
				# TODO: make thresholds a dashed or different colored line
				pp "printing threshold #{t}"
				x = vis.add(pv.Rule)
					.data(t[:data])
					.bottom(lambda {|d| vert.scale(d)})
					.height(1)
					.lineWidth(0.5)
					.antialias(true)
					.strokeStyle(t[:colour])
						.add(pv.Label)                                      
						.right(-5)                                           
						.textAlign("left")
						.textBaseline("middle")
						.text(t[:title])
			}

	      # legend/key
	      if @legend
	         names_and_indexes = (0...@data_series.size()).zip(
	            @data_series.collect {|d| d[0]}
	         )
	         vis.add(pv.Dot)
	            .data(names_and_indexes)
	            .left(lambda { |x| x[0]*60 + 20})
	            .top(10)
	            .stroke_style(lambda { |x| c.scale(x[0])})
	            .fill_style(lambda { |x| c.scale(x[0]).alpha(0.2)})
	            .shape_size(3) 
	            .anchor("right").add(pv.Label)
	               .text(lambda {|x| x[1]})
	               .textBaseline("top")
	       
	      end
	
	      ## Postconditions & return:
	      vis.render()
	      return vis.to_svg()
	   end
	
	end
	

end


### END ###
