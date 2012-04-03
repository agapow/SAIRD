#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

# Reads a series of seasonal thresholds from an excel spreadsheet.
#
module ThresholdReader
	
	### IMPORTS
	
	require 'roo'
	require 'pp'
	
	
	### CONSTANTS & DEFINES	
	
	THRESH_SYNONYMS = {
		"pathogen_type" => :pathogen_type,
		"name" => :pathogen_type,
		"pathogen" => :pathogen_type,
		"type" => :pathogen_type,
		"virus" => :pathogen_type,
		"virus_type" => :pathogen_type,
		"strain" => :pathogen_type
	}
	
	
	### IMPLEMENTATION ###
	
	class ExcelReader < SpreadsheetReader::ExcelReader
		
		def initialize(infile, file_type)
			super(infile, file_type)
			@syn_dict = THRESH_SYNONYMS
		end
		
	end
	
end


### END ###
