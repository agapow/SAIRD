class RenameVirus < ActiveRecord::Migration
  def self.up
    rename_table :virus_types, :pathogen_types

    rename_column :susceptibilities, :virus_type_id, :pathogen_type_id

    rename_column :thresholds, :virus_type_id, :pathogen_type_id

    change_column :user_countries, :level, :string, :limit => 255, :default => :editor

    remove_index :susceptibilities, :name => :index_susceptibilities_on_virus_type_id rescue ActiveRecord::StatementInvalid
    add_index :susceptibilities, [:pathogen_type_id]

    remove_index :thresholds, :name => :index_thresholds_on_virus_type_id rescue ActiveRecord::StatementInvalid
    add_index :thresholds, [:pathogen_type_id]
  end

  def self.down
    rename_column :susceptibilities, :pathogen_type_id, :virus_type_id

    rename_column :thresholds, :pathogen_type_id, :virus_type_id

    change_column :user_countries, :level, :string, :default => "'--- :editor\n'"

    rename_table :pathogen_types, :virus_types

    remove_index :susceptibilities, :name => :index_susceptibilities_on_pathogen_type_id rescue ActiveRecord::StatementInvalid
    add_index :susceptibilities, [:virus_type_id]

    remove_index :thresholds, :name => :index_thresholds_on_pathogen_type_id rescue ActiveRecord::StatementInvalid
    add_index :thresholds, [:virus_type_id]
  end
end
