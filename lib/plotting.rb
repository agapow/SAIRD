#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
# Utilities for producing plots


### IMPORTS
# See notes on this implementation in tool_forms

require './lib/plotting/base_plotter.rb'

Dir['./lib/plotting/*.rb'].each { |lib|
	require lib
}


### IMPLEMENTATION
#
module Plotting


end


### TESTING ###

if $0 == __FILE__
	require 'pp'
	pp "calling main"
end


### END ###
