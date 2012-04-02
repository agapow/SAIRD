#!/usr/bin/env ruby
# -*- coding: utf-8 -*-


### IMPLEMENTATION

module Plotting
   
   ### IMPORTS
   
	require 'rubyvis'
	require 'date.rb'
	
	
   ### CONSTANTS & DEFINES 
   
   
   ### IMPLEMENTATION ###
	
	class BasePlotter
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
		def bounds(arr, kwargs={})
	      ## Preconditions:
	      opts = OpenStruct.new({
	         :log => false
	      }.merge(kwargs))   
	   	
	      ## Main:
		   min, max = arr.min(), arr.max()
		   range = max - min
		
		   # how many figures in the range
		   range_digits = Math.log10(range).ceil()
		   range_scale = 10.0**(range_digits-1)
		
		   # because you can't divide dates or time, handle those manually
		   #if min.class == Date
		   margin = range / 10 + 1
		   if opts.log
				min_bound = [min, 0].max() * 0.67
				max_bound = max * 1.5
			else
				min_bound = [min - margin, 0].max()
				max_bound = max + margin
			end
		   #elsif min.class == Time
		   #   min_bound = min - 100000
		   #   max_bound = max + 100000
		   #else
		   #   min_bound = ((min / range_scale) - 1) * range_scale
		   #   max_bound = ((max / range_scale) + 1) * range_scale
		   #end
		   return min_bound, max_bound, range_scale
		end
	end

end


### END ###
