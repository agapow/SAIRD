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
	         :season_thresholds => nil,
	         :extrapolated_thresholds => nil,
	         :outliers => []
	      }.merge(kwargs))   
	   	
	      pp "whisker outliers are #{opts.outliers}"
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
	      data_min = (@data_series.collect { |col| col.w_bottom } + opts.outliers).min()
	      data_max = (@data_series.collect { |col| col.w_top } + opts.outliers).max()
	      possible_range = [data_min, data_max]
	      if ! opts.season_thresholds.nil?
	         possible_range.concat opts.season_thresholds
	      end
			if ! opts.extrapolated_thresholds.nil?
			   possible_range.concat opts.extrapolated_thresholds
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
	         .left(60)
	         .bottom(20)
	         .top(10)
	         .right(75)
	       
	         
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
	         .strokeStyle(lambda { |d| label_ticks.member?(d) ?  "blue" : "lightblue" })
	         .line_width(0.5)
	         .antialias(true)
	         .add(pv.Label)                                      
	            .left(-5)                                           
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
	      
			pp "OUTLIERS #{opts.outliers}"
			if ! opts.outliers.empty?
				pp "OUTLIERS"
				pp opts.outliers
			  vis.add(pv.Dot)
			      .data(opts.outliers)
			      .left(horiz.scale(0.5))
			      .bottom(lambda {|d| vert.scale(d)})
			      .stroke_style("red")
			      .fill_style("grey")
			      .shape_size(3)
			end

			threshold_data = [
				{
					:title => 'current',
					:data => opts.season_thresholds.nil? ? [] : opts.season_thresholds,
					:colour => "green",
				},
				{
					:title => 'extrapolated',
					:data => opts.extrapolated_thresholds.nil? ? [] : opts.extrapolated_thresholds,
					:colour => 'yellow',
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
					
				pp x.class

			}
			
#vis.add(pv.Rule)
#.data(vert.ticks())  
#.bottom(lambda {|d| vert.scale(d)})                             
#.strokeStyle(lambda { |d| label_ticks.member?(d) ?  "blue" : "lightblue" })
#.line_width(0.5)
#.antialias(true)
#.add(pv.Label)                                      
#.left(0)                                           
#.textAlign("right")
#.textBaseline("middle")
#.text(lambda {|d| label_ticks.member?(d) ?  sprintf("%0.2f", d) : '' })
      	
#   vis.add(pv.Rule)
#      .data(opts.season_thresholds)
#      .bottom(lambda {|d| vert.scale(d)})
#      .height(1)
#      .anchor("left")
#      .lineWidth(@canvas_wt)
#      .strokeStyle(lambda {|d| pv.color("red") })
#      .antialias(true)


	      vis.render()
	      return vis.to_svg()
	   end
	

	   
	end


end


### END ###
