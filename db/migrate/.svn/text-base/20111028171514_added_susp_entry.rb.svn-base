class AddedSuspEntry < ActiveRecord::Migration
  def self.up
    create_table :susceptibility_entries do |t|
      t.float    :measure
      t.datetime :created_at
      t.datetime :updated_at
      t.integer  :susceptibility_id
      t.integer  :drug_id
    end
    add_index :susceptibility_entries, [:susceptibility_id]
    add_index :susceptibility_entries, [:drug_id]

    change_column :user_countries, :level, :string, :limit => 255, :default => :editor
  end

  def self.down
    change_column :user_countries, :level, :string, :default => "'--- :editor\n'"

    drop_table :susceptibility_entries
  end
end
