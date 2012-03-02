class RenameFileToAttachment < ActiveRecord::Migration
  def self.up
    rename_column :downloads, :file_file_name, :attachment_file_name
    rename_column :downloads, :file_content_type, :attachment_content_type
    rename_column :downloads, :file_file_size, :attachment_file_size
    rename_column :downloads, :file_updated_at, :attachment_updated_at

    change_column :user_countries, :level, :string, :limit => 255, :default => :editor
  end

  def self.down
    rename_column :downloads, :attachment_file_name, :file_file_name
    rename_column :downloads, :attachment_content_type, :file_content_type
    rename_column :downloads, :attachment_file_size, :file_file_size
    rename_column :downloads, :attachment_updated_at, :file_updated_at

    change_column :user_countries, :level, :string, :default => "'--- :editor\n'"
  end
end
