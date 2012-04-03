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

					new_thr = build_threshold(rec)
					new_thr.country = params[:country]
					new_thr.season = params[:season]
					
					# TODO: will this error out if there is a previous one?
					new_thr.validate()
					if ! new_thr.errors.empty?
						raise StandardError, new_thr.errors.full_messages[0]
					end
					
					thr_name = "#{new_thr.country} / #{new_thr.season} / #{new_thr.pathogen_type}"
					pp '----', "THRESHOLD #{thr_name}"
					new_thr.thresholdentries.each { |thr_ent|
						pp "#{thr_ent.resistance}: #{thr_ent.minor}-#{thr_ent.major}"
					}
				
					# check if record already exists
					# note isolate name must be globally unique
					old_thr = Threshold.scoped(:conditions => {
						:country_id => new_thr.country_id,
						:season_id => new_thr.season_id,
						:pathogen_type_id => new_thr.pathogen_type_id
					})
					if ! old_thr.nil?
						old_thr = old_thr.all[0]
					end
					
					if params[:dryrun]
						if old_thr.nil? or params[:overwrite]
							results << "Row/threshold #{new_thr.pathogen_type} read successfully"
						else
							raise StandardError, 'already an threshold for that country / season / pathogen combination'
						end
					else
						if old_thr.nil?
							thr_to_save = new_thr
							action_name = "saved"
						elsif params[:overwrite]
							# update shit
							old_thr.description = new_thr.description
							old_thr.thresholdentries = new_thr.thresholdentries
	
							thr_to_save = old_thr
							action_name = "updated"
						else
							raise StandardError, 'already an threshold for that country / season / pathogen combination'
						end
	
						thr_to_save.save()
						if thr_to_save.errors.empty?
							results << "Threshold #{rec[:isolate_name]} #{action_name} successfully"
						else
							sr_to_save.errors.full_messages.each { |m|
								errors << "Problem with row/entry #{rec[:isolate_name]}: #{m}"
							}
						end
					end
					
				rescue StandardError => err
					errors << "Problem with row/threshold for #{rec[:pathogen_type]}: #{err}"
				rescue
					errors << "Unknown problem with row/threshold for #{rec[:pathogen_type]}"
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
