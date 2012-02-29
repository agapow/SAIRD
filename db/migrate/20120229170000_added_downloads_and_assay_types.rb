class AddedDownloadsAndAssayTypes < ActiveRecord::Migration
  def self.up
    create_table :downloads do |t|
      t.string   :title
      t.text     :description
      t.datetime :created_at
      t.datetime :updated_at
      t.integer  :uploader_id
      t.string   :file_file_name
      t.string   :file_content_type
      t.integer  :file_file_size
      t.datetime :file_updated_at
    end
    add_index :downloads, [:uploader_id]

    add_column :susceptibility_sequences, :assay, :string
    add_column :susceptibility_sequences, :assay_other, :string

    change_column :user_countries, :level, :string, :limit => 255, :default => :editor
  end

  def self.down
    remove_column :susceptibility_sequences, :assay
    remove_column :susceptibility_sequences, :assay_other

    change_column :user_countries, :level, :string, :default => "'--- :editor\n'"

    drop_table :downloads
  end
end
