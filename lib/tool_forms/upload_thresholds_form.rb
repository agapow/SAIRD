#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

# Tool for bulk uploading of threshold data.

### IMPORTS


### IMPLEMENTATION

module ToolForms

	# A tool to handle the excel bulk uploads
	class UploadThresholdsForm < BaseToolForm
		
		def self.title
			return 'Bulk upload of seasonal thresholds'
		end
		
		def self.description
			return """Upload multiple seasonal thresholds reports into the
				database via an Excel spreadsheet."""
		end
		
		def self.id
			return 'uploadthresholds'
		end
		
		def self.form_method
			return "POST"
		end
		
		## Services:
		def self.is_valid?(params)
			pp "**** params #{params}"
			errors = []
			clean_params = {}
			if params['spreadsheet'].nil?
				errors << "need to upload a spreadsheet"
			else
				clean_params[:spreadsheet] = params['spreadsheet']
			end
			
			clean_params[:country] = Country.find_by_id(params['country'])
			clean_params[:season] = Season.find_by_id(params['season'])
			clean_params[:dryrun] = params['dryrun'] != "0"
			
			# check stuff
			if clean_params[:country].nil? then errors << "unknown country" end
			if clean_params[:season].nil? then errors << "unknown season" end
			
			return clean_params, errors
		end
		
		
		# Return all resistance reports for this season & virus type & country
		def self.process_default(params)
			## Preconditions & preparation:
			errors = []
			results = []
			## Main:
			# figure out file type
			sheet_file = params[:spreadsheet]
			sheet_file_name = sheet_file.original_filename
			file_ext = sheet_file_name[/\.\w+$/]
			if file_ext.nil?
				return [], ["can't determine file type of '#{sheet_file_name}'"]
			end
			file_ext = file_ext[1,file_ext.size].downcase()
			if ! ['xls', 'xlsx'].member?(file_ext)
				return [], ["can't handle files of type '#{file_ext}'"]
			end
			
			rdr = ThresholdReader::ExcelReader.new(sheet_file.local_path, file_ext)
			rdr.read() { |rec|
				begin
					pp rec
					new_threshold = build_threshold(rec)
					new_threshold.country = params[:country]
					new_threshold.season = params[:season]
						
					new_threshold.validate()
					pp new_threshold.errors
					if params[:dryrun]
						results << "Threshold for #{rec[:pathogen_type]} read successfully"
					else
						new_threshold.save()
						results << "Threshold for #{rec[:pathogen_type]} saved successfully"
					end
				rescue StandardError => err
					errors << "Problem with threshold for #{rec[:pathogen_type]}: #{err}"
				rescue
					errors << "Unknown problem with threshold for #{rec[:pathogen_type]}"
				end
			}
		
			# Postconditions & returns:
			return results, errors
		end
		
		def self.build_threshold(rec)
			if [nil, ''].member?(rec[:pathogen_type])
				raise StandardError, 'needs an pathogen type'
			end
			new_threshold = Threshold.new(:pathogen_type=>rec[:pathogen_type])
			
			# Other fields
			threshold_entries = []
			rec.each_pair { |k,v|
				if [:pathogen_type].member?(k)
					next
				end
				
				if [nil, ''].member?(v)
					next
				end
						
				pp k, v
				
				res = Resistance.find(:first,
					:conditions => [ "lower(agent) = ?", k.downcase() ]
				)
						
				if ! res.nil?
					new_entry = Thresholdentry.new(
						:resistance => res,
					)
					
					# now parse cutoffs
					pp "HERE"
					pp v
					cutoffs = v.gsub('-',',').split(',').collect { |c|
						c.strip.to_f()
					}
					pp cutoffs
					if cutoffs.length != 2
						raise StandardError, "malformed cutoffs, need 2 not #{len(cutoffs)}"
					else
						new_entry.minor = cutoffs[0]
						new_entry.major = cutoffs[1]
					end
					
					pp new_entry
					threshold_entries << new_entry
				else
					raise StandardError, "unrecognised resistance '#{k}'"
				end
			}
			
			new_threshold.thresholdentries = threshold_entries
			
			## Postconditions & return:
			pp new_threshold
			return new_threshold
		end
		
	end

end


### END
