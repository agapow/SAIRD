class RenameDrugName < ActiveRecord::Migration
  def self.up
    rename_column :resistances, :name, :agent

    change_column :mutations, :description, :string, :limit => 255

    change_column :user_countries, :level, :string, :limit => 255, :default => :editor
  end

  def self.down
    rename_column :resistances, :agent, :name

    change_column :mutations, :description, :text

    change_column :user_countries, :level, :string, :default => "'--- :editor\n'"
  end
end
