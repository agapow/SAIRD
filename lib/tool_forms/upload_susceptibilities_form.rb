#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

# Tool for bulk uploading of susceptibility data.

### IMPORTS


### IMPLEMENTATION

module ToolForms

	# A tool to handle the excel bulk uploads
	class UploadSusceptibilitiesForm < BaseToolForm
		
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
			clean_params[:dryrun] = params['dryrun'] != "0"
			
			# check stuff
			if clean_params[:country].nil? then errors << "unknown country" end
			
			return clean_params, errors
		end
		
		
		# Return the generated resistance reports
		#
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
					pp "Heres what we got"
					pp rec
					new_sr = build_suscep_report(rec)
					new_sr.country = params[:country]
					pp params
					#new_sr.season = params[:season]
					#new_sr.pathogen_type = params[:pathogen_type]
					pp new_sr
						
					if params[:dryrun]
						results << "Report #{rec[:isolate_name]} read successfully"
					else
						prev_recs = Susceptibility.scoped(:conditions => {:isolate_name => new_sr.isolate_name})
						if 0 < prev_recs.length
							raise StandardError, "there is already a susceptibility entry with that name"
						end
						new_sr.save()
						if new_sr.errors.empty?
							results << "Report #{rec[:isolate_name]} saved successfully"
						else
							new_sr.errors.full_messages.each { |m|
								errors << "Problem with report #{rec[:isolate_name]}: #{m}"
							}
						end
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
			season = Season.find_by_year(rec[:season].to_i)
			if season.nil?
				raise StandardError, "can't find the season named '#{rec[:season]}'"
			end			
			pathogen_type = PathogenType.find_by_name(rec[:pathogen_type])
			if pathogen_type.nil?
				raise StandardError, "can't find the pathogen type named '#{rec[:pathogen_type]}'"
			end	
			new_sr = Susceptibility.new(:isolate_name=>rec[:isolate_name],
				:collected=>rec[:collected], :season => season,
				:pathogen_type => pathogen_type)
			if ! [nil, ''].member?(rec[:comment])
				new_sr.comment = rec[:comment]
			end
			
			# patient fields
			patient_data = {}
			seq_resistance_data = {}
			rec.each_pair { |k,v|
				if [:isolate_name, :collected, :comment, :season, :pathogen_type].member?(k)
					next
				elsif SuscepReader::PATIENT_COLS.member?(k)
					patient_data[k] = v
				else
					seq_resistance_data[k] = v
				end
			}

			new_sr.susceptibility_entries, new_sr.susceptibility_sequences =
				build_pheno_geno(seq_resistance_data)
				
			new_patient = build_patient(patient_data)
			if ! new_patient.nil?
				new_sr.patients << new_patient
			end
			
			## Postconditions & return:
			return new_sr
		end
		
		
		def self.build_pheno_geno(rec)
			pp "ENTERINg BUILD GENO PHENO"
			suscep_entries = []
			sequences = []
			rec.each_pair { |k,v|
				
				
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
					pp "ENTERERING MUTATIONS"
					mutations = v.split(',').collect { |m|
						pp "mutations"
						pp m
						
						mut = m.strip.upcase.split(/\s+/, 2).collect { |s| s.strip }
						pp mut
						mut_desc = mut[0]
						if mut_desc.match(/^[A-Z]?\d+[A-Z]$/).nil?
							raise StandardError, "error in mutation description for '#{m}', must match format [X]123Y [45%]"
						end
						if mut.length == 1
							# no percent
							pp "MAKING MUTATION JUST DESC"

							SequenceMutation.new(:description => mut_desc)
						else
							mut_percent_match = mut[1].match(/\A(\d+)\%?\Z/)
							if mut_percent_match.nil?
								raise StandardError, "error in mutation percent for '#{m}', must match format [X]123Y [45%]"
							else
								mut_percent = mut_percent_match[1].to_i
								pp "MAKING MUTATION WITH PORP"
								SequenceMutation.new(:description => mut_desc,
									:magnitude => mut_percent)
							end
						end
					}
					suscep_seq = SusceptibilitySequence.new(:gene => gen,
						:sequence_mutations => mutations)
					sequences << suscep_seq
				else
					raise StandardError, "unrecognised gene or resistance '#{k}'"
				end
			}
		pp "LEAVING BUILD GENO PHENO"

			return suscep_entries, sequences
		end

		def self.build_patient(rec)
			passed_fields = {}
			rec.each_pair { |k,v|
				if ! [nil, ''].member?(v)
					passed_fields[k] = v
				end
			}
			if passed_fields.length() == 0
				return nil
			else
				new_p = Patient.new()
				
				passed_fields.each_pair { |k,v|
					if k == :patient_date_of_birth
						new_p.date_of_birth = v
					elsif k == :patient_date_of_illness
						new_p.date_of_illness = v
					elsif k == :patient_gender
						new_p.gender = v
					elsif k ==  :patient_location
						new_p.location = v
					elsif k ==  :patient_vaccinated
						new_p.vaccinated = v
					elsif k ==  :patient_antivirals
						new_p.antivirals = v
					elsif k ==  :patient_household
						new_p.household_contact = v
					elsif k ==  :patient_disease
						new_p.disease_progression = v
					elsif k ==  :patient_complication
						new_p.disease_complication = v
					elsif k ==  :patient_hospitalized
						new_p.hospitalized = v
					elsif k ==  :patient_death
						new_p.death = v
					else
						# TODO: raise error
					end
				}
				
				return new_p
				
			end
		end

		
	end

end


### END
