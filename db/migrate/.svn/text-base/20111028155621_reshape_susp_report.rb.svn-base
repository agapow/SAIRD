class ReshapeSuspReport < ActiveRecord::Migration
  def self.up
    drop_table :susceptibility_report_entries

    add_column :drugs, :unit, :text

    rename_column :susceptibilities, :date_specimen_collected, :collected
    remove_column :susceptibilities, :virus_type
    remove_column :susceptibilities, :title
    remove_column :susceptibilities, :iC50_zanamivir_MUNANA_nm
    remove_column :susceptibilities, :iC50_zanamivir_na_star_nm
    remove_column :susceptibilities, :iC50_zanamivir_other_nm
    remove_column :susceptibilities, :iC50_oseltamivir_munana_nm
    remove_column :susceptibilities, :iC50_oseltamivir_na_star_nm
    remove_column :susceptibilities, :iC50_oseltamivir_other_nm
    remove_column :susceptibilities, :iC50_amantadine_um
    remove_column :susceptibilities, :iC50_rimantadine_um
    remove_column :susceptibilities, :na_sequence
    remove_column :susceptibilities, :ha_sequence
    remove_column :susceptibilities, :m2_sequence
    remove_column :susceptibilities, :dob
    remove_column :susceptibilities, :gender
    remove_column :susceptibilities, :date_onset_of_illness
    remove_column :susceptibilities, :hospitalised
    remove_column :susceptibilities, :institution
    remove_column :susceptibilities, :community
    remove_column :susceptibilities, :other
    remove_column :susceptibilities, :not_known
    remove_column :susceptibilities, :source_virus_sentinel
    remove_column :susceptibilities, :source_virus_non_sentinel
    remove_column :susceptibilities, :other_namely
    remove_column :susceptibilities, :vaccinated_for_current_flu_season
    remove_column :susceptibilities, :no_exposure_to_flu_antivirals_patient
    remove_column :susceptibilities, :yes_exposure_to_flu_antivirals_patient
    remove_column :susceptibilities, :yes_exposure_to_flu_antivirals_patient_which_drug
    remove_column :susceptibilities, :not_known_exposure_to_flu_antivirals_patient
    remove_column :susceptibilities, :no_exposure_to_flu_antivirals_household_contact
    remove_column :susceptibilities, :yes_exposure_to_flu_antivirals_household_contact
    remove_column :susceptibilities, :yes_exposure_to_flu_antivirals_household_contact_which_drug
    remove_column :susceptibilities, :not_known_exposure_to_flu_antivirals_household_contact
    remove_column :susceptibilities, :geographic_location
    remove_column :susceptibilities, :disease_progression_uncomplicated
    remove_column :susceptibilities, :disease_progression_complicated
    remove_column :susceptibilities, :disease_progression_complicated_pneumonia
    remove_column :susceptibilities, :disease_progression_complicated_otitis_media
    remove_column :susceptibilities, :disease_progression_complicated_other
    remove_column :susceptibilities, :disease_progression_complicated_namely
    remove_column :susceptibilities, :disease_progression_not_known
    remove_column :susceptibilities, :hospitalisation
    remove_column :susceptibilities, :death
    remove_column :susceptibilities, :csv_file_name
    remove_column :susceptibilities, :csv_content_type
    remove_column :susceptibilities, :csv_file_size
    remove_column :susceptibilities, :csv_updated_at
    remove_column :susceptibilities, :na_sequence_aa
    remove_column :susceptibilities, :ha_sequence_aa
    remove_column :susceptibilities, :m2_sequence_aa

    remove_column :thresholds, :zanamivir_munana_minor_outlier
    remove_column :thresholds, :zanamivir_munana_major_outlier
    remove_column :thresholds, :zanamivir_nastar_minor_outlier
    remove_column :thresholds, :zanamivir_nastar_major_outlier
    remove_column :thresholds, :zanamivir_other_minor_outlier
    remove_column :thresholds, :zanamivir_other_major_outlier
    remove_column :thresholds, :oseltamivir_munana_minor_outlier
    remove_column :thresholds, :oseltamivir_munana_major_outlier
    remove_column :thresholds, :oseltamivir_nastar_minor_outlier
    remove_column :thresholds, :oseltamivir_nastar_major_outlier
    remove_column :thresholds, :oseltamivir_other_minor_outlier
    remove_column :thresholds, :oseltamivir_other_major_outlier
    remove_column :thresholds, :amantadine_munana_minor_outlier
    remove_column :thresholds, :amantadine_munana_major_outlier
    remove_column :thresholds, :rimantadine_munana_minor_outlier
    remove_column :thresholds, :rimantadine_munana_major_outlier

    change_column :user_countries, :level, :string, :limit => 255, :default => :editor
  end

  def self.down
    remove_column :drugs, :unit

    rename_column :susceptibilities, :collected, :date_specimen_collected
    add_column :susceptibilities, :virus_type, :string
    add_column :susceptibilities, :title, :string
    add_column :susceptibilities, :iC50_zanamivir_MUNANA_nm, :decimal
    add_column :susceptibilities, :iC50_zanamivir_na_star_nm, :decimal
    add_column :susceptibilities, :iC50_zanamivir_other_nm, :decimal
    add_column :susceptibilities, :iC50_oseltamivir_munana_nm, :decimal
    add_column :susceptibilities, :iC50_oseltamivir_na_star_nm, :decimal
    add_column :susceptibilities, :iC50_oseltamivir_other_nm, :decimal
    add_column :susceptibilities, :iC50_amantadine_um, :decimal
    add_column :susceptibilities, :iC50_rimantadine_um, :decimal
    add_column :susceptibilities, :na_sequence, :string
    add_column :susceptibilities, :ha_sequence, :string
    add_column :susceptibilities, :m2_sequence, :string
    add_column :susceptibilities, :dob, :date
    add_column :susceptibilities, :gender, :string
    add_column :susceptibilities, :date_onset_of_illness, :date
    add_column :susceptibilities, :hospitalised, :boolean
    add_column :susceptibilities, :institution, :boolean
    add_column :susceptibilities, :community, :boolean
    add_column :susceptibilities, :other, :boolean
    add_column :susceptibilities, :not_known, :boolean
    add_column :susceptibilities, :source_virus_sentinel, :boolean
    add_column :susceptibilities, :source_virus_non_sentinel, :boolean
    add_column :susceptibilities, :other_namely, :string
    add_column :susceptibilities, :vaccinated_for_current_flu_season, :string
    add_column :susceptibilities, :no_exposure_to_flu_antivirals_patient, :boolean
    add_column :susceptibilities, :yes_exposure_to_flu_antivirals_patient, :boolean
    add_column :susceptibilities, :yes_exposure_to_flu_antivirals_patient_which_drug, :string
    add_column :susceptibilities, :not_known_exposure_to_flu_antivirals_patient, :boolean
    add_column :susceptibilities, :no_exposure_to_flu_antivirals_household_contact, :boolean
    add_column :susceptibilities, :yes_exposure_to_flu_antivirals_household_contact, :boolean
    add_column :susceptibilities, :yes_exposure_to_flu_antivirals_household_contact_which_drug, :string
    add_column :susceptibilities, :not_known_exposure_to_flu_antivirals_household_contact, :boolean
    add_column :susceptibilities, :geographic_location, :string
    add_column :susceptibilities, :disease_progression_uncomplicated, :boolean
    add_column :susceptibilities, :disease_progression_complicated, :boolean
    add_column :susceptibilities, :disease_progression_complicated_pneumonia, :boolean
    add_column :susceptibilities, :disease_progression_complicated_otitis_media, :boolean
    add_column :susceptibilities, :disease_progression_complicated_other, :boolean
    add_column :susceptibilities, :disease_progression_complicated_namely, :string
    add_column :susceptibilities, :disease_progression_not_known, :boolean
    add_column :susceptibilities, :hospitalisation, :string
    add_column :susceptibilities, :death, :string
    add_column :susceptibilities, :csv_file_name, :string
    add_column :susceptibilities, :csv_content_type, :string
    add_column :susceptibilities, :csv_file_size, :integer
    add_column :susceptibilities, :csv_updated_at, :datetime
    add_column :susceptibilities, :na_sequence_aa, :string
    add_column :susceptibilities, :ha_sequence_aa, :string
    add_column :susceptibilities, :m2_sequence_aa, :string

    add_column :thresholds, :zanamivir_munana_minor_outlier, :float
    add_column :thresholds, :zanamivir_munana_major_outlier, :float
    add_column :thresholds, :zanamivir_nastar_minor_outlier, :float
    add_column :thresholds, :zanamivir_nastar_major_outlier, :float
    add_column :thresholds, :zanamivir_other_minor_outlier, :float
    add_column :thresholds, :zanamivir_other_major_outlier, :float
    add_column :thresholds, :oseltamivir_munana_minor_outlier, :float
    add_column :thresholds, :oseltamivir_munana_major_outlier, :float
    add_column :thresholds, :oseltamivir_nastar_minor_outlier, :float
    add_column :thresholds, :oseltamivir_nastar_major_outlier, :float
    add_column :thresholds, :oseltamivir_other_minor_outlier, :float
    add_column :thresholds, :oseltamivir_other_major_outlier, :float
    add_column :thresholds, :amantadine_munana_minor_outlier, :float
    add_column :thresholds, :amantadine_munana_major_outlier, :float
    add_column :thresholds, :rimantadine_munana_minor_outlier, :float
    add_column :thresholds, :rimantadine_munana_major_outlier, :float

    change_column :user_countries, :level, :string, :default => "'--- :editor\n'"

    create_table "susceptibility_report_entries", :force => true do |t|
      t.float    "result"
      t.datetime "created_at"
      t.datetime "updated_at"
    end
  end
end
