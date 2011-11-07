#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

# Reads a series of seasonal thresholds from an excel spreadsheet.
#
module ThresholdReader
	
	### IMPORTS
	
	require 'roo'
	require 'pp'
	
	
	### CONSTANTS & DEFINES	
	
	COLNAMES = {
		"pathogen_type" => :pathogen_type,
		"name" => :pathogen_type,
		"pathogen" => :pathogen_type,
		"type" => :pathogen_type,
		"virus" => :pathogen_type,
		"virus_type" => :pathogen_type,
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
