#!/usr/bin/env ruby
# -*- coding: utf-8 -*-


module Plotting

   # Return the 25th, 50th & 75th percentile
   #
   def quartiles (arr)
      # There are all sorts of definitions of percentiles and quartiles. The
      # most common is for quartiles to be the 25/50/75th percentile.
      # Percentile is calculated the value at the integer position that least
      # exceeds the required percentage position in the array. Thus we add 0.5
      # and round off. However, since this gives you a 1-based index, to map
      # to our 0-based arrays, we subtract 1.

      vals = arr.sort()
      len = vals.size()
      # find (1-based) positions in array for quartiles
      i25 = ((len * 0.25) - 0.5).round()
      i50 = ((len * 0.50) - 0.5).round()
      i75 = ((len * 0.75) - 0.5).round()
      # get actual values from array
      p25 = vals[i25-1]
      p50 = vals[i50-1]
      p75 = vals[i75-1]

      return [p25, p50, p75]
   end
   module_function :quartiles

	# Returns the positions for a whisker & box plot, specifically whisker
	# bottom, q25, q50, q75, whisker top
	#
	def whisker_and_box_bounds (arr, kwargs={})
	   ## Preconditions:
	   opts = OpenStruct.new({
	      :log => false,
	   }.merge(kwargs))
	   
	   pp "arr #{arr}"
	   ## Main:
	   # transform vals if required
	   if opts.log
	   	vals = arr.collect { |v| Math::log(v) }
	   else
	   	vals = arr
	   end
	   pp "vals #{vals}"
		
	   qs = quartiles(vals)
	   pp "qs #{qs}"
		if opts.log
			qs = qs.collect { |v| Math::exp(v) }
		end
	   pp "qs #{qs}"
		
		p25 = qs[0]
		p50 = qs[1]
		p75 = qs[2]
		
		iqr = p75 - p25
		w_top_limit = p75 + (1.5 * iqr)
		top_vals = arr.select { |v| (p75 < v) and (v <= w_top_limit) }
		if top_vals.nil? or top_vals.empty?
			w_top_val = w_top_limit
		else
			w_top_val = top_vals.max()
		end
		w_bottom_limit = [0.0, p25 - (1.5 * iqr)].max()
		bottom_vals = arr.select { |v| (v < p25) and (w_bottom_limit <= v) }
		if bottom_vals.nil?  or bottom_vals.empty?
			w_bottom_val = w_bottom_limit
		else
			w_bottom_val = bottom_vals.min()
		end

	## Postconditions & return:
      return w_bottom_val, p25, p50, p75, w_top_val
   end
   module_function :whisker_and_box_bounds


end


### END ###
