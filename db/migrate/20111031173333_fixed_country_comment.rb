class FixedCountryComment < ActiveRecord::Migration
  def self.up
    change_column :user_countries, :level, :string, :limit => 255, :default => :editor
  end

  def self.down
    change_column :user_countries, :level, :string, :default => "'--- :editor\n'"
  end
end
