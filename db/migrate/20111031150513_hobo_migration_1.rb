class HoboMigration1 < ActiveRecord::Migration
  def self.up
    create_table :susceptibility_sequences do |t|
      t.datetime :created_at
      t.datetime :updated_at
    end

    create_table :sequence_mutations do |t|
      t.text :description
    end

    add_column :sequences, :gene_id, :integer
    remove_column :sequences, :created_at
    remove_column :sequences, :updated_at
    remove_column :sequences, :na_sequence
    remove_column :sequences, :ha_sequence
    remove_column :sequences, :m2_sequence
    remove_column :sequences, :comment

    add_column :patients, :date_of_birth, :date
    add_column :patients, :date_of_illness, :date
    add_column :patients, :antivirals, :string
    add_column :patients, :household_contact, :string
    add_column :patients, :disease_progression, :string
    add_column :patients, :disease_complication, :string
    add_column :patients, :hospitalized, :string
    add_column :patients, :death, :string
    remove_column :patients, :title
    remove_column :patients, :dob
    remove_column :patients, :date_onset_of_illness
    change_column :patients, :vaccinated, :string, :limit => 255

    change_column :user_countries, :level, :string, :limit => 255, :default => :editor

    add_index :sequences, [:gene_id]
  end

  def self.down
    remove_column :sequences, :gene_id
    add_column :sequences, :created_at, :datetime
    add_column :sequences, :updated_at, :datetime
    add_column :sequences, :na_sequence, :string
    add_column :sequences, :ha_sequence, :string
    add_column :sequences, :m2_sequence, :string
    add_column :sequences, :comment, :text

    remove_column :patients, :date_of_birth
    remove_column :patients, :date_of_illness
    remove_column :patients, :antivirals
    remove_column :patients, :household_contact
    remove_column :patients, :disease_progression
    remove_column :patients, :disease_complication
    remove_column :patients, :hospitalized
    remove_column :patients, :death
    add_column :patients, :title, :string
    add_column :patients, :dob, :date
    add_column :patients, :date_onset_of_illness, :date
    change_column :patients, :vaccinated, :boolean

    change_column :user_countries, :level, :string, :default => "'--- :editor\n'"

    drop_table :susceptibility_sequences
    drop_table :sequence_mutations

    remove_index :sequences, :name => :index_sequences_on_gene_id rescue ActiveRecord::StatementInvalid
  end
end
