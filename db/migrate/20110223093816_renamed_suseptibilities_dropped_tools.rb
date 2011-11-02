class RenamedSuseptibilitiesDroppedTools < ActiveRecord::Migration
  def self.up
    rename_table :suseptibility_report_entries, :susceptibility_report_entries
    rename_table :suseptibilities, :susceptibilities

    drop_table :tools

    rename_column :ic50_datas, :suseptibility_id, :susceptibility_id

    rename_column :sequences, :suseptibility_id, :susceptibility_id

    rename_column :patients, :suseptibility_id, :susceptibility_id

    remove_index :ic50_datas, :name => :index_ic50_datas_on_suseptibility_id rescue ActiveRecord::StatementInvalid
    add_index :ic50_datas, [:susceptibility_id]

    remove_index :susceptibilities, :name => :index_suseptibilities_on_season_id rescue ActiveRecord::StatementInvalid
    add_index :susceptibilities, [:season_id]

    remove_index :sequences, :name => :index_sequences_on_suseptibility_id rescue ActiveRecord::StatementInvalid
    add_index :sequences, [:susceptibility_id]

    remove_index :patients, :name => :index_patients_on_suseptibility_id rescue ActiveRecord::StatementInvalid
    add_index :patients, [:susceptibility_id]
  end

  def self.down
    rename_column :ic50_datas, :susceptibility_id, :suseptibility_id

    rename_column :sequences, :susceptibility_id, :suseptibility_id

    rename_column :patients, :susceptibility_id, :suseptibility_id

    rename_table :susceptibility_report_entries, :suseptibility_report_entries
    rename_table :susceptibilities, :suseptibilities

    create_table "tools", :force => true do |t|
      t.string   "title"
      t.text     "description"
      t.text     "parameters"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "tooltype"
      t.string   "icon_file_name"
      t.string   "icon_content_type"
      t.integer  "icon_file_size"
      t.datetime "icon_updated_at"
    end

    remove_index :ic50_datas, :name => :index_ic50_datas_on_susceptibility_id rescue ActiveRecord::StatementInvalid
    add_index :ic50_datas, [:suseptibility_id]

    remove_index :suseptibilities, :name => :index_susceptibilities_on_season_id rescue ActiveRecord::StatementInvalid
    add_index :suseptibilities, [:season_id]

    remove_index :sequences, :name => :index_sequences_on_susceptibility_id rescue ActiveRecord::StatementInvalid
    add_index :sequences, [:suseptibility_id]

    remove_index :patients, :name => :index_patients_on_susceptibility_id rescue ActiveRecord::StatementInvalid
    add_index :patients, [:suseptibility_id]
  end
end
