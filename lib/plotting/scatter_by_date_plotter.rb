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
	         :thresholds => nil,     
	      }.merge(kwargs))   
	
	      ## Main:
	      pp data
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
	      x_min, x_max = x_data.min(), x_data.max()
	      x_bounds = bounds([x_min, x_max])
	
	      y_data = @data_series.collect { |series|
	         series[1].collect { |pt|
	            pt[1]
	         }
	      }.flatten()
	      y_min, y_max = y_data.min(), y_data.max()
	      possible_range = [y_min, y_max]
	      if ! opts.thresholds.nil?
	         possible_range.concat (opts.thresholds)
	      end
	      pp possible_range
	      y_bounds = bounds(possible_range)
	      pp y_bounds
	      
	      # make area for plotting
	      # ???: adhoc values for left, etc. set padding for labels
	      vis = pv.Panel.new()
	         .width(@canvas_wt)
	         .height(@canvas_ht)
	         .left(30)
	         .bottom(20)
	         .top(10)
	         .right(10)
	      
	      # scaling to position datapoints in plot
	      horiz = pv.Scale.linear(x_bounds[0], x_bounds[1]).nice().range(0, @plot_wt)
	      
	      pp "LOG IS #{@log}"
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
	      horiz_label_ticks = horiz.ticks.each_slice(2).map(&:first)
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
	      
	      vert_label_ticks = vert.ticks.each_slice(2).map(&:first)
	      vis.add(pv.Rule)
	         .data(vert.ticks())
	         .bottom(vert)
	         .stroke_style(lambda {|d| d!= vert.ticks()[0] ? "#eee" : "#000"})
	         .add(pv.Label)
	            .left(0)
	            .text_margin(5)
	            .text(vert.tick_format)
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
	
	      if ! opts.thresholds.nil?
	         # TODO: make thresholds a dashed or different colored line
	         thresholds = opts.thresholds.sort()
	         min_threshold = thresholds[0]
	         max_threshold = thresholds[1]
	
	         pp "doing thresholds"
	
	         vis.add(pv.Rule)
	            .data(thresholds)
	            .bottom(lambda {|d| vert.scale(d)})
	            .height(1)
	            .anchor("left")
	            .lineWidth(@canvas_wt)
	            .strokeStyle(lambda {|d| pv.color("red") })
	            .antialias(true)
	                  
	      end
	
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
