# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20120320112224) do

  create_table "countries", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
  end

  create_table "downloads", :force => true do |t|
    t.string   "title"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "uploader_id"
    t.string   "attachment_file_name"
    t.string   "attachment_content_type"
    t.integer  "attachment_file_size"
    t.datetime "attachment_updated_at"
  end

  add_index "downloads", ["uploader_id"], :name => "index_downloads_on_uploader_id"

  create_table "genes", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "ic50_datas", :force => true do |t|
    t.decimal  "iC50_zanamivir_MUNANA_nm"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "iC50_zanamivir_na_star_nm"
    t.decimal  "iC50_zanamivir_other_nm"
    t.decimal  "iC50_oseltamivir_munana_nm"
    t.decimal  "iC50_oseltamivir_na_star_nm"
    t.decimal  "iC50_oseltamivir_other_nm"
    t.decimal  "iC50_amantadine_um"
    t.decimal  "iC50_rimantadine_um"
    t.string   "title"
    t.integer  "susceptibility_id"
  end

  add_index "ic50_datas", ["susceptibility_id"], :name => "index_ic50_datas_on_susceptibility_id"

  create_table "mutations", :force => true do |t|
    t.integer  "sequence_id"
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "susceptibility_sequence_id"
  end

  add_index "mutations", ["susceptibility_sequence_id"], :name => "index_mutations_on_susceptibility_sequence_id"

  create_table "news_items", :force => true do |t|
    t.string   "name"
    t.text     "body"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "poster_id"
  end

  add_index "news_items", ["poster_id"], :name => "index_news_items_on_poster_id"

  create_table "pathogen_types", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "patient_locations", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "patients", :force => true do |t|
    t.string   "location"
    t.string   "gender"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "susceptibility_id"
    t.string   "vaccinated"
    t.date     "date_of_birth"
    t.date     "date_of_illness"
    t.string   "antivirals"
    t.string   "household_contact"
    t.string   "disease_progression"
    t.string   "disease_complication"
    t.string   "hospitalized"
    t.string   "death"
  end

  add_index "patients", ["susceptibility_id"], :name => "index_patients_on_susceptibility_id"

  create_table "resistances", :force => true do |t|
    t.string   "agent"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "unit"
  end

  create_table "seasons", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "year"
  end

  create_table "sequence_mutations", :force => true do |t|
    t.string  "description",                :limit => 6
    t.integer "susceptibility_sequence_id"
    t.integer "magnitude"
  end

  add_index "sequence_mutations", ["susceptibility_sequence_id"], :name => "index_sequence_mutations_on_susceptibility_sequence_id"

  create_table "susceptibilities", :force => true do |t|
    t.string   "isolate_name"
    t.date     "collected"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "comment"
    t.integer  "season_id"
    t.integer  "country_id"
    t.integer  "pathogen_type_id"
  end

  add_index "susceptibilities", ["country_id"], :name => "index_susceptibilities_on_country_id"
  add_index "susceptibilities", ["pathogen_type_id"], :name => "index_susceptibilities_on_pathogen_type_id"
  add_index "susceptibilities", ["season_id"], :name => "index_susceptibilities_on_season_id"

  create_table "susceptibility_entries", :force => true do |t|
    t.float    "measure"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "susceptibility_id"
    t.integer  "resistance_id"
  end

  add_index "susceptibility_entries", ["resistance_id"], :name => "index_susceptibility_entries_on_resistance_id"
  add_index "susceptibility_entries", ["susceptibility_id"], :name => "index_susceptibility_entries_on_susceptibility_id"

  create_table "susceptibility_sequences", :force => true do |t|
    t.string  "title"
    t.integer "susceptibility_id"
    t.integer "gene_id"
    t.string  "assay"
    t.string  "assay_other"
  end

  add_index "susceptibility_sequences", ["gene_id"], :name => "index_susceptibility_sequences_on_gene_id"
  add_index "susceptibility_sequences", ["susceptibility_id"], :name => "index_susceptibility_sequences_on_susceptibility_id"

  create_table "thresholdentries", :force => true do |t|
    t.float    "minor"
    t.float    "major"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "threshold_id"
    t.integer  "resistance_id"
  end

  add_index "thresholdentries", ["resistance_id"], :name => "index_thresholdentries_on_resistance_id"
  add_index "thresholdentries", ["threshold_id"], :name => "index_thresholdentries_on_threshold_id"

  create_table "thresholds", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "description"
    t.integer  "season_id"
    t.integer  "country_id"
    t.integer  "pathogen_type_id"
  end

  add_index "thresholds", ["country_id"], :name => "index_thresholds_on_country_id"
  add_index "thresholds", ["pathogen_type_id"], :name => "index_thresholds_on_pathogen_type_id"
  add_index "thresholds", ["season_id"], :name => "index_thresholds_on_season_id"

  create_table "user_countries", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.integer  "country_id"
    t.string   "level",      :default => "--- :editor\n"
  end

  add_index "user_countries", ["country_id"], :name => "index_user_countries_on_country_id"
  add_index "user_countries", ["user_id"], :name => "index_user_countries_on_user_id"

  create_table "users", :force => true do |t|
    t.string   "crypted_password",          :limit => 40
    t.string   "salt",                      :limit => 40
    t.string   "remember_token"
    t.datetime "remember_token_expires_at"
    t.string   "name"
    t.string   "email_address"
    t.boolean  "administrator",                           :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "state",                                   :default => "inactive"
    t.datetime "key_timestamp"
    t.string   "user_name"
  end

  add_index "users", ["state"], :name => "index_users_on_state"

end
