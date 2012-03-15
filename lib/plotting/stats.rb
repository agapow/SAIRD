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

   def whisker_and_box_bounds (arr)
      # Returns the positions for a whisker & box plot, specifically whisker
      # bottom, q25, q50, q75, whisker top

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


end


### END ###
