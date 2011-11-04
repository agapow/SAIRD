#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

# Tool for bulk uploading of susceptibility data.

### IMPORTS


### IMPLEMENTATION

module ToolForms

	# A tool to handle the excel bulk uploads
	class UploadExcelToolForm < BaseToolForm
		
		def self.title
			return 'Bulk upload of susceptibility data'
		end
		
		def self.description
			return """Upload multiple susceptibility reports into the database
				via an Excel spreadsheet."""
		end
		
		def self.id
			return 'bulkupload'
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
			clean_params[:pathogen_type] = PathogenType.find_by_id(params['pathogen'])
			clean_params[:dryrun] = params['dryrun'] != "0"
			clean_params[:overwrite] = params['overwrite'] != "0"
			
			# check stuff
			if clean_params[:country].nil? then errors << "unknown country" end
			if clean_params[:season].nil? then errors << "unknown season" end
			if clean_params[:pathogen_type].nil? then errors << "unknown pathogen" end
			
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
			
			rdr = SuscepReader::ExcelReader.new(sheet_file.local_path, file_ext)
			rdr.read() { |rec|
				begin
					pp rec
					new_sr = build_suscep_report(rec)
					new_sr.country = params[:country]
					new_sr.season = params[:season]
					new_sr.pathogen_type = params[:pathogen_type]
						
					if params[:dryrun]
						results << "Report #{rec[:isolate_name]} read successfully"
					else
						new_sr.save()
						results << "Report #{rec[:isolate_name]} saved successfully"
					end
				rescue StandardError => err
					errors << "Problem with report #{rec[:isolate_name]}: #{err}"
				rescue
					errors << "Unknown problem with report #{rec[:isolate_name]}"
				end
			}
		
			# Postconditions & returns:
			return results, errors
		end
		
		def self.build_suscep_report(rec)
			if [nil, ''].member?(rec[:isolate_name])
				raise StandardError, 'needs an isolate name'
			end
			if Susceptibility.find_by_isolate_name(rec[:isolate_name])
				raise StandardError, 'already a report with that name'
			end
			if [nil, ''].member?(rec[:collected])
				raise StandardError, 'needs a collection date'
			end
			new_sr = Susceptibility.new(:isolate_name=>rec[:isolate_name],
				:collected=>rec[:collected])
			if ! [nil, ''].member?(rec[:comment])
				new_sr.comment = rec[:comment]
			end
			
			# Other fields
			suscep_entries = []
			sequences = []
			rec.each_pair { |k,v|
				if [:isolate_name, :collected, :comment].member?(k)
					next
				end
				
				if [nil, ''].member?(v)
					next
				end
						
				pp k, v
				
				res = Resistance.find(:first,
					:conditions => [ "lower(agent) = ?", k.downcase() ])
				gen = Gene.find(:first,
					:conditions => [ "lower(name) = ?", k.downcase() ])
						
				if ! res.nil?
					suscep_entry = SusceptibilityEntry.new(
						:resistance => res,
						:measure => v.to_f
					)
					suscep_entries << suscep_entry
		
				elsif ! gen.nil?
					mutations = v.split(',').collect { |m|
						SequenceMutation.new(:description => m.strip)
					}
					suscep_seq = SusceptibilitySequence.new(:gene => gen,
						:sequence_mutations => mutations)
					sequences << suscep_seq
				else
					raise StandardError, "unrecognised gene or resistance '#{k}'"
				end
			}
			
			new_sr.susceptibility_entries = suscep_entries
			new_sr.susceptibility_sequences = sequences
			
			## Postconditions & return:
			pp new_sr
			return new_sr
		end
		
	end

end


### END
