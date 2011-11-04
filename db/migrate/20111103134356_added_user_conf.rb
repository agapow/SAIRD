class AddedUserConf < ActiveRecord::Migration
  def self.up
    change_column :users, :state, :string, :limit => 255, :default => "inactive"

    change_column :user_countries, :level, :string, :limit => 255, :default => :editor
  end

  def self.down
    change_column :users, :state, :string, :default => "active"

    change_column :user_countries, :level, :string, :default => "'--- :editor\n'"
  end
end
