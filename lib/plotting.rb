#!/usr/bin/env ruby

# -*- coding: utf-8 -*-

# Utilities for producing plots
#
module Plotting
   
   ### IMPORTS
   
	require 'rubyvis'
	require 'date.rb'
	
	
   ### CONSTANTS & DEFINES 
   
   
   ### IMPLEMENTATION ###
	
	class Plotter
		# Return neat bounds for graphing purposes
		#
		# @param [Array] arr   figures to fall within bounds.
		#
		# @returns min, max, unit
		#
		# For graphing purposes, we need to know how much "space" to put around
		# the depicted figures. That is, if we are graphing values of 61, 62 and 64, it
		# is wasteful to graph 0 to 100. Graphing from 61 to 64 strictly is cramped.
		# This function assesses the range of the data and returns bounds based on that,
		# that put some distance around the data.
		#
		# @example
		#    bounds([7,5,2,0])      # => [-1.0, 8.0, 1.0]
		#    bounds([20.5, 21.2])   # => [20.4, 21.3, 0.1]
		#
		def bounds(arr)
		   min, max = arr.min(), arr.max()
		   range = max - min
		
		   # how many figures in the range
		   range_digits = Math.log10(range).ceil()
		   range_scale = 10.0**(range_digits-1)
		
		   # because you can't divide dates or time, handle those manually
		   if min.class == Date
		      margin = range / 10 + 1
		      min_bound = min - margin
		      max_bound = max + margin
		   elsif min.class == Time
		      min_bound = min - 100000
		      max_bound = max + 100000
		   else
		      min_bound = ((min / range_scale) - 1) * range_scale
		      max_bound = ((max / range_scale) + 1) * range_scale
		   end
		   return min_bound, max_bound, range_scale
		end
	end
	
	
	# Renders data as a box-and-whisker plot
	#
	# The object is instantiated with style details for the plot and can be used
	# (via render) to draw several different plots.
	#
	class WhiskerPlotter < Plotter
	   
	   attr_accessor(
	      :data_quartiles,  # [[name, q0, q1, q2, q3, q4], ...]
	      :plot_wt,
	      :plot_ht,
	      :canvas_wt,
	      :canvas_ht,
	      :margin,
	      :title,
	      :bar_clr,
	      :whisker_clr,
	      :legend,
	   )
	   
	   def initialize(kwargs={})
	      ## Preconditions:
	      opts = OpenStruct.new({
	         :plot_ht => 250,
	         :plot_wt => 400,
	         :margin => 0,
	         :title => nil,
	         :bar_clr => "blue",
	         :whisker_clr => "blue",
	         :legend => true,      
	      }.merge(kwargs))
	      ## Main:
	      @plot_ht = opts.plot_ht
	      @plot_wt = opts.plot_wt
	      @margin = opts.margin
	      @canvas_ht = opts.plot_ht + (2 * @margin)
	      @canvas_wt = opts.plot_wt + (2 * @margin)
	      @title = opts.title
	      @bar_clr = opts.bar_clr
	      @whisker_clr = opts.whisker_clr
	      @legend = opts.legend
	   end
	   
	   # Create a plot of the passed data and return as an SVG.
	   #
	   # @param [] data   an array of pairs, being [name, [data]]
	   #
	   def render_data(data, kwargs={})
	      ## Preconditions:
	      opts = OpenStruct.new({
	         :thresholds => nil,     
	      }.merge(kwargs))   
	
	      # calculate quartiles for plot, use this as data
	      @data_series = data.collect { |row|
	         data = bottom_25_median_75_top(row[1])
	         OpenStruct.new(
	            :name => row[0],
	            :w_bottom => data[0],
	            :q25 => data[1],
	            :q50 => data[2],
	            :q75 => data[3],
	            :w_top => data[4],
	            :index => 0
	         )                                      
	      }
	      # NOTE: need index to lay out coloumns horizontally
	      @data_series.each_with_index { |d, i|
	         d.index = i
	      }
	      # find limits of data so we know where axes are
	      data_min = @data_series.collect { |col| col.w_bottom }.min()
	      data_max = @data_series.collect { |col| col.w_top }.max()
	      possible_range = [data_min, data_max]
	      if ! opts.thresholds.nil?
	         possible_range.concat opts.thresholds
	      end
	      bounds = bounds(possible_range)
	      plot_range = bounds[1] - bounds[0]
	
	      
	      # make area for plotting
	      # left, etc. set padding so actual size is ht/wt + padding
	      vis = pv.Panel.new()
	         .width(@canvas_wt)
	         .height(@canvas_ht)
	         .margin(@margin)
	         .left(30)
	         .bottom(20)
	         .top(10)
	         .right(10)
	         
	      # adhoc guess at bar width
	      bar_width = @plot_wt / @data_series.size() * 0.8
	      
	      # scaling to position datapoints in plot
	      vert = pv.Scale.linear(bounds[0], bounds[1]).range(0, @plot_ht)
	      horiz = pv.Scale.linear(0, @data_series.size()).range(0, @plot_wt)
	
	      # where to draw labels on graph
	      label_ticks = vert.ticks.each_slice(4).map(&:first)
	
	      # make horizontal lines:
	      # - what values are drawn
	      # - where the bottom of it appears
	      # - what color to make the line
	      # - the width of the line
	      # - antialias it?
	      # - add a label
	      #   - where does label appear relative to line
	      #   - how is the text aligned in own space
	      #   - align text vertically ("top" looks like "middle")
	      #   - what appears in the label
	      vis.add(pv.Rule)
	         .data(vert.ticks())  
	         .bottom(lambda {|d| vert.scale(d)})                             
	         .strokeStyle(lambda { |d| label_ticks.member?(d) ?  "black" : "lightblue" })
	         .line_width(0.5)
	         .antialias(true)
	         .add(pv.Label)                                      
	            .left(0)                                           
	            .textAlign("right")
	            .textBaseline("top")
	            .text(lambda {|d| label_ticks.member?(d) ?  sprintf("%0.2f", d) : '' })             
	      
	      # y (vertical) axis
	      vis.add(pv.Rule)
	         .data([0])
	         .left(horiz.scale(0))
	         .bottom(@margin)
	         .strokeStyle("black")
	         
	      # make the main body of boxplot
	      vis.add(pv.Rule)
	         .data(@data_series)
	         .left(lambda {|d| horiz.scale(d.index + 0.5) })
	         .bottom(lambda {|d| vert.scale(d.q25)})
	         .lineWidth(bar_width)
	         .height(lambda {|d| vert.scale(d.q75) - vert.scale(d.q25)})
	         .strokeStyle(@bar_clr)
	
	      # add bottom labels
	      if @legend
	         vis.add(pv.Label)
	            .data(@data_series)
	            .left(lambda {|d| horiz.scale(d.index + 0.5) })
	            .bottom(0)
	            .text_baseline("top")
	            .text_margin(15)
	            .textAlign("center")
	            .text(lambda {|d| d.name })
	      end
	
	      # make the whisker      
	      vis.add(pv.Rule)
	         .data(@data_series)
	         .left(lambda {|d| horiz.scale(d.index + 0.5)})
	         .bottom(lambda {|d| vert.scale(d.w_bottom)})
	         .lineWidth(1)
	         .height(lambda {|d| vert.scale(d.w_top) - vert.scale(d.w_bottom)})
	         .strokeStyle(@bar_clr)
	
	      # make the median line     
	      vis.add(pv.Rule)
	         .data(@data_series)
	         .left(lambda {|d| horiz.scale(d.index + 0.5)})
	         .bottom(lambda {|d| vert.scale(d.q50)})
	         .height(1)
	         .lineWidth(bar_width)
	         .strokeStyle("white")
	      
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
	
	      vis.render()
	      return vis.to_svg()
	   end
	
	   # Takes a numeric array and returns the min, q1, q2 (median), q3, max.
	   #
	   # @param [Array]  arr  a list or array
	   #
	   # There's a number of ways of calculating percentiles (and thus quartiles),
	   # especially when it comes to interpolating between points. This uses the
	   # simplest continuous method, doing a weighted sum of neighbouring values.
	   #
	   def quartiles(arr)
	      sort_arr = arr.sort()
	      len = sort_arr.size()
	      q1_q2_q3 = [0.25, 0.5, 0.75].collect { |v|
	         indx_f = (len * v) - 0.5
	         indx_i = indx_f.to_i()
	         if (indx_i == indx_f)
	            sort_arr[indx_i]
	         else
	            res = indx_f - indx_i
	            (sort_arr[indx_i] * (1 - res)) + (sort_arr[indx_i+1] * res)
	         end
	      }
	      return [sort_arr[0]] + q1_q2_q3 + [sort_arr[-1]] 
	   end
	
	   # Given an array of values, calculate 25, 50, 75 quartiles and whisker limits
	   #
	   def bottom_25_median_75_top (arr)
	      vals = arr.sort()
	      len = vals.size()
	      # find (1-based) positions in array for quartiles
	      i25 = (len * 0.25).ceil()
	      i50 = (len * 0.50).round()
	      i75 = (len * 0.75).floor()
	      # get actual values from array
	      p25 = vals[i25-1]
	      p50 = vals[i50-1]
	      p75 = vals[i75-1]
	
	      # calculate whisker top & bottomiqr = p75 - p25
	      iqr = p75 - p25
	      w_top = p75 + (1.5 * iqr)
	      w_top_val = vals.select { |v| v <= w_top }.max
	      w_bottom = p25 - (1.5 * iqr)
	      w_bottom_val = [vals.select { |v| w_bottom <= v }.min, 0].max
	
	      return [w_bottom_val, p25, p50, p75, w_top_val] 
	   end
	   
	end
	
	
	
	# Renders data as a scatter plot where ponts are [date, val]
	# 
	# Oddly enough, rubyvis can only handle Times not dates, so you have to pass Time structures
	#
	class ScatterByDatePlotter  < Plotter
	   
	   attr_accessor(
	      :data_series,  # [[name, [[x1, y1], ], ...]
	      :plot_wt,
	      :plot_ht,
	      :canvas_wt,
	      :canvas_ht,
	      :margin,
	      :title,
	   )
	   
	   def initialize(kwargs={})
	      ## Preconditions:
	      opts = OpenStruct.new({
	         :plot_ht => 250,
	         :plot_wt => 400,
	         :legend => true,   
	      }.merge(kwargs))
	      ## Main:
	      @plot_ht = opts.plot_ht
	      @plot_wt = opts.plot_wt
	      @canvas_ht = opts.plot_ht
	      @canvas_wt = opts.plot_wt
	      @legend = opts.legend
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
	      vert = pv.Scale.linear(y_bounds[0], y_bounds[1]).nice().range(0, @plot_ht)
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
					.text(lambda {|d| "#{d}"})
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
