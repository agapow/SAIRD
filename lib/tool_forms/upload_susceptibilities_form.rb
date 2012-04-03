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
			return """Upload multiple susceptibility entries into the database
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
			errors = []
			clean_params = {}
			if params['spreadsheet'].nil?
				errors << "need to upload a spreadsheet"
			else
				clean_params[:spreadsheet] = params['spreadsheet']
			end

			clean_params[:country] = Country.find_by_id(params['country'])
			clean_params[:dryrun] = params['dryrun'] != "0"
			clean_params[:overwrite] = params['overwrite'] != "0"

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
			pp '', "PARAMS", params

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
					new_sr = build_suscep_report(rec)
					new_sr.country = params[:country]

					# check record does not already exist
					# note isolate name must be globally unique
					old_sr = Susceptibility.find_by_isolate_name (new_sr.isolate_name)

					pp '----', "ISOLATE #{new_sr.isolate_name}"
					pp '', "SUSP", new_sr.susceptibility_entries, new_sr.susceptibility_sequences
					new_sr.susceptibility_entries.each { |sus_ent|
						pp "#{sus_ent.resistance} #{sus_ent.measure}"
					}

					if params[:dryrun]
						if old_sr.nil? or params[:overwrite]
							results << "Row/entry #{rec[:isolate_name]} read successfully"
						else
							raise StandardError, 'already an entry with that name'
						end
					else
						if old_sr.nil?
							sr_to_save = new_sr
							action_name = "saved"
						elsif params[:overwrite]
							# update shit
							# NOTE: so you can't overwrite other countries, we don't
							# let that field be updated
							if old_sr.country != new_sr.country
								raise StandardError, 'pre-existing entry belongs to another country'
							end

							old_sr.collected = new_sr.collected
							old_sr.comment = new_sr.comment
							old_sr.season = new_sr.season
							old_sr.pathogen_type = new_sr.pathogen_type
							old_sr.susceptibility_entries = new_sr.susceptibility_entries
							old_sr.susceptibility_sequences = new_sr.susceptibility_sequences
							old_sr.patients = new_sr.patients

							sr_to_save = old_sr
							action_name = "updated"
						else
							raise StandardError, 'already an entry with that name'
						end

						sr_to_save.save()
						if sr_to_save.errors.empty?
							results << "Entry #{rec[:isolate_name]} #{action_name} successfully"
						else
							sr_to_save.errors.full_messages.each { |m|
								errors << "Problem with row/entry #{rec[:isolate_name]}: #{m}"
							}
						end
					end
				rescue StandardError => err
					errors << "Problem with row/entry #{rec[:isolate_name]}: #{err}"
				rescue
					errors << "Unknown problem with row/entry #{rec[:isolate_name]}"
				end
			}

			# Postconditions & returns:
			return results, errors
		end

		def self.build_suscep_report(rec)
			if [nil, ''].member?(rec[:isolate_name])
				raise StandardError, 'needs an isolate name'
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
			# required fields
			if new_sr.collected.nil?
				raise StandardError, "needs a date of collection"
			elsif new_sr.isolate_name.nil? or new_sr.isolate_name.strip.blank?
				raise StandardError, "needs a name"
			elsif new_sr.season.nil?
				raise StandardError, "needs a season"
			elsif new_sr.pathogen_type.nil?
				raise StandardError, "needs a season"
			end

			# needs some sort of resistance data
			if new_sr.susceptibility_entries.empty? and new_sr.susceptibility_sequences.empty?
				raise StandardError, "must have phenotypic or genotypic resistance data"
			end

			# check isolate date
			yr_str = new_sr.season.year.to_s
			if new_sr.isolate_name.index(yr_str).nil?
				raise StandardError, "isolate name does not contain year"
			end

			return new_sr
		end

		def self.build_pheno_geno(rec)
			suscep_entries = []
			sequences = []
			rec.each_pair { |k,v|

				if [nil, ''].member?(v)
					next
				end

				res = Resistance.find(:first,
				:conditions => [ "lower(agent) = ?", k.downcase() ])
				gen = Gene.find(:first,
				:conditions => [ "lower(name) = ?", k.downcase() ])

				# if a resistance (drug) was found, create a SusceptibilityEntry
				if ! res.nil?
					# need to check if formatted in Excel as number or string or whatever
					if [Float, Fixnum].member?(v.class)
						measure_val = v
					elsif [String].member?(v.class)
						measure_val = v.downcase()
						# NOTE: doesn't allow ints, e.g. 100
						if measure_val.match(/\A[0-9]*\.?[0-9]+\Z/).nil?
							pp "REGEX FORMAT ERROR: ", v
							raise StandardError, "format error in phenotypic resistance value for '#{measure_val}', must be a floating point value"
						end
					else
						pp "EXCEL FORMAT ERROR: ", v, v.class
						raise StandardError, "unrecognised Excel format in phenotypic resistance value for '#{measure_val}', must be a text or a number"
					end
					
					suscep_entry = SusceptibilityEntry.new(
					:resistance => res,
					:measure => measure_val.to_f
					)
					suscep_entries << suscep_entry

				elsif ! gen.nil?
					mutations = v.split(',').collect { |m|

						mut = m.strip.upcase.split(/\s+/, 2).collect { |s| s.strip }
						mut_desc = mut[0]
						if mut_desc.match(/^[A-Z]?\d+[A-Z]$/).nil?
							raise StandardError, "error in mutation description for '#{m}', must match format '[X]123Y [#%]'"
						end
						if mut.length == 1
							# no percent

							SequenceMutation.new(:description => mut_desc)
						else
							mut_percent_match = mut[1].match(/\A(\d+)\%?\Z/)
							if mut_percent_match.nil?
								raise StandardError, "error in mutation percent for '#{m}', must match format '[X]123Y [#%]'"
							else
								mut_percent = mut_percent_match[1].to_i
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
