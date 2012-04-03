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
			clean_params[:overwrite] = params['overwrite'] != "0"
			
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
			pp '----', "PARAMS", params
				
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
					pp '*', 'THRESHOLD REC', rec
					new_threshold = build_threshold(rec)
					new_threshold.country = params[:country]
					new_threshold.season = params[:season]
					
					pp '*', 'THRESHOLD FOR DB', new_threshold.pathogen_type, new_threshold.country, new_threshold.season
					new_threshold.thresholdentries.each { |te|
						pp "#{te.resistance}: #{te.minor}-#{te.major}"
					}
					
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
			## Preconditions:
			pp '*', 'BUILD THRESH REC', rec
			
			## Main:
			if [nil, ''].member?(rec[:pathogen_type])
				raise StandardError, 'needs an pathogen type'
			end
			new_threshold = Threshold.new(:pathogen_type=>rec[:pathogen_type])
			
			# Other fields
			threshold_entries = []
				
			# for each column
			rec.each_pair { |k,v|
				
				# skip pathogen col of course
				if [:pathogen_type].member?(k)
					next
				end
				
				# skip empty columns
				if [nil, ''].member?(v)
					next
				end
						
				pp k, v
				
				res = Resistance.find(:first,
					:conditions => [ "lower(agent) = ?", k.downcase() ]
				)
						
				if res.nil?
					raise StandardError, "unrecognised resistance or drug '#{k}'"
				end
				
				# now parse cutoffs
				if v.class != String
					raise StandardError, "unrecognised Excel format in threshold values for '#{k}', must be text"
				end
				cutoffs = v.gsub('-',',').split(',').collect { |c|
					c.strip
				}
				pp cutoffs
				if cutoffs.length != 2
					raise StandardError, "unrecognised format in threshold values for '#{k}', need two in format 'X-Y'"
				end
				cutoff_floats = cutoffs.collect { |c|
					if c.match(/\A[0-9]*\.?[0-9]+\Z/).nil?
						pp "REGEX FORMAT ERROR: ", c
						raise StandardError, "unrecognised format in threshold values for '#{k}', must be floating-point values"
					else
						c.to_f
					end
				}
				pp cutoff_floats
				if cutoff_floats[1] <= cutoff_floats[0]
					raise StandardError, "unrecognised format in threshold values for '#{k}', major value must be more than minor"
				end
				
					
				threshold_entries << Thresholdentry.new(
					:resistance => res,
					:minor => cutoff_floats[0],
					:major => cutoff_floats[1]
				)
			}
			
			new_threshold.thresholdentries = threshold_entries
			
			## Postconditions & return:
			pp new_threshold
			return new_threshold
		end
		
	end

end


### END
