class RenameDrug < ActiveRecord::Migration
  def self.up
    rename_table :drugs, :resistances

    rename_column :thresholdentries, :drug_id, :resistance_id

    rename_column :susceptibility_entries, :drug_id, :resistance_id

    change_column :user_countries, :level, :string, :limit => 255, :default => :editor

    remove_index :thresholdentries, :name => :index_thresholdentries_on_drug_id rescue ActiveRecord::StatementInvalid
    add_index :thresholdentries, [:resistance_id]

    remove_index :susceptibility_entries, :name => :index_susceptibility_entries_on_drug_id rescue ActiveRecord::StatementInvalid
    add_index :susceptibility_entries, [:resistance_id]
  end

  def self.down
    rename_column :thresholdentries, :resistance_id, :drug_id

    rename_column :susceptibility_entries, :resistance_id, :drug_id

    change_column :user_countries, :level, :string, :default => "'--- :editor\n'"

    rename_table :resistances, :drugs

    remove_index :thresholdentries, :name => :index_thresholdentries_on_resistance_id rescue ActiveRecord::StatementInvalid
    add_index :thresholdentries, [:drug_id]

    remove_index :susceptibility_entries, :name => :index_susceptibility_entries_on_resistance_id rescue ActiveRecord::StatementInvalid
    add_index :susceptibility_entries, [:drug_id]
  end
end
