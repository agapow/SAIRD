#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

# Reads a series of susceptibility reports from an excel spreadsheet.
#
module SuscepReader
	
	### IMPORTS
	
	require 'roo'
	require 'pp'
	
	
	### CONSTANTS & DEFINES	
	
	COLNAMES = {
		"name" => :name,
		"isolate" => :isolate_name,
		"isolate_name" => :isolate_name,
		"collected" => :collected,
		"date_collected" => :collected,
		"comment" => :comment,
		"note" => :note,
	}
	
	
	### IMPLEMENTATION ###
	
	class ExcelReader < SpreadsheetReader::ExcelReader
		
		# Clean up the title of a column to something reasonable
		#
		# If the header is one of the essentials
		def clean_col_header (hdr)
			return COLNAMES.fetch(hdr.downcase.gsub(' ', '_'), hdr)
		end
		
	end
	
end


### END ###
