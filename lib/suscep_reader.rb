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
		"year" => :season,
		"season" => :season,
		"pathogen" => :pathogen_type,
		"pathogen_type" => :pathogen_type,
		"subtype" => :pathogen_type,
		
	}
	
	OTHER_FIELDS = {
		:patient_date_of_birth => [
			:patient_dob,
			:date_of_birth,
			:birth,
			:patient_birth,
		],
		
		:patient_date_of_illness => [
			:patient_doi,
			:date_of_illness,
			:illness,
			:patient_illness,
		],
		:patient_gender => [
			:gender,
			:patient_sex,
			:sex
		],
			
		:patient_location => [
			:location
		],
		
		:patient_vaccinated => [
			:vaccinated,
			:vaccination,
			:patient_vaccination,
		]
		
		:patient_antivirals = [
			:antivirals,
		]
			
		:patient_household = [
			:household,
			:household_contact,
			:patient_household_contact,
		]
		:patient_disease => [
			:disease,
			:disease_progression,
			:patient_disease_progression,
		]
		
		:patient_complication => [
			:patient_disease_complication,
			:disease_complication,
		]
		
		:patient_hospitalized => [
			:hospitalized,
			:hospitalised,
			:patient_hospitalised,
			:hospital,
		]
		
		:patient_death => [
			:patient_dead,
			:death,
			:dead,
		]
		
		

		antivirals            Patient::AntiviralExposure
		disease_progression   Patient::Progression
	}
	
	OTHER_FIELDS.each_pair { |k, v|
		v.each { |s|
			COLNAMES[v.to_s] = k
		}
		COLNAMES[k.to_s] = k
	}
	
	### IMPLEMENTATION ###
	
	class ExcelReader < SpreadsheetReader::ExcelReader
		
		def initialize(infile, file_type)
			super(infile, file_type)
			@syn_dict = COLNAMES
		end
		
		def convert_season (raw_arg)
			season = raw_arg.to_i()
			print "The season is #{season}"
			return season
		end
		
		def convert_patient_gender (raw_val)
			val = raw_val.strip.downcase()
			return {
				:m => :male,
				:f => :female,
				:male => :male,
				:female => :female
			}.fetch(val.to_sym(), val)
		end
		
		def convert_tristate (raw_val)
			val = raw_val.strip.downcase()
			return {
				:y => :yes,
				:n => :no,
				:yes => :yes,
				:no => :no
			}.fetch(val.to_sym(), val)
		end
		
		def convert_vaccinated(raw_val)
			return convert_tristate(raw_val)
		end
		
		def convert_patient_household(raw_val)
			return convert_tristate(raw_val)
		end
		
		def convert_patient_hospitalized(raw_val)
			return convert_tristate(raw_val)
		end
		
		def convert_patient_death(raw_val)
			return convert_tristate(raw_val)
		end
	
		def convert_patient_antivirals(raw_val)
			val = raw_val.strip.downcase()
			return {
				:patienttreated => :patientTreated,
				:patientpostexposureprophylaxis => :patientPostExposureProphylaxis,
				:contacttreated => :contactTreated,
				::contactpostexposureprophylaxis => :contactPostExposureProphylaxis,
				:patient_treated => :patientTreated,
				:patient_post_exposure_prophylaxis => :patientPostExposureProphylaxis,
				:contact_treated => :contactTreated,
				::contact_post_exposure_prophylaxis => :contactPostExposureProphylaxis,
				:n => :no,
				:no => :no
				:unknown => :unknown,
				:"?" => :unknown,
				:"" => :unknown,
			}.fetch(val.to_sym(), val)
		end
		
		def convert_patient_patient_disease(raw_val)
			val = raw_val.strip.downcase()
			return {
				:complicated => :complicated,
				:uncomplicated => :uncomplicated,
				:unknown => :unknown,
				:complication => :complicated,
				:"?" => :unknown,
				:"" => :unknown,
			}.fetch(val.to_sym(), val)
		end	
		
	end
	
end


### END ###
