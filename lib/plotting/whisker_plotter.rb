#!/usr/bin/env ruby
# -*- coding: utf-8 -*-


module Plotting
	
	# Renders data as a box-and-whisker plot
	#
	# The object is instantiated with style details for the plot and can be used
	# (via render) to draw several different plots.
	#
	class WhiskerPlotter < BasePlotter
	   
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
	      :log,
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
	         :legend => true,#
	         :log => false,
	         :calc_thresholds => false,
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
	      @log = opts.log
	   end
	   
	   # Create a plot of the passed data and return as an SVG.
	   #
	   # @param [] data   an array of pairs, being [name, [data]] where
	   #    the data is the points of the plot
	   #
	   def render_data(data, kwargs={})
	      ## Preconditions:
	      opts = OpenStruct.new({
	         :thresholds => nil,
	         :outliers => []
	      }.merge(kwargs))   
	
	      # calculate quartiles for plot, use this as data
	      @data_series = data.collect { |row|
	         OpenStruct.new(
	            :name => row[0],
	            :w_bottom => row[1][0],
	            :q25 => row[1][1],
	            :q50 => row[1][2],
	            :q75 => row[1][3],
	            :w_top => row[1][4],
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
	      pp "The bounds are #{bounds}"
	      plot_range = bounds[1] - bounds[0]
	
	      
	      # make area for plotting
	      # left, etc. set padding so actual size is ht/wt + padding
	      vis = pv.Panel.new()
	         .width(@canvas_wt)
	         .height(@canvas_ht)
	         .margin(@margin)
	         .left(50)
	         .bottom(20)
	         .top(10)
	         .right(10)
	         
	      # adhoc guess at bar width
	      bar_width = @plot_wt / @data_series.size() * 0.7
	      
	      # scaling to position datapoints in plot
			if @log == true
				vert = pv.Scale.log(bounds[0]+0.01, bounds[1]).range(0, @plot_ht)
			else
				vert = pv.Scale.linear(bounds[0], bounds[1]).range(0, @plot_ht)
			end
	      horiz = pv.Scale.linear(0, @data_series.size()).range(0, @plot_wt)
	
	      # where to draw labels on graph
	      label_ticks = vert.ticks.each_slice(5).map(&:first)
	
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
	            .textBaseline("middle")
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


end


### END ###
