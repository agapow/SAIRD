class LimitedMutationAndMagnitude < ActiveRecord::Migration
  def self.up
    change_column :user_countries, :level, :string, :limit => 255, :default => :editor

    change_column :sequence_mutations, :description, :string, :limit => 6
    change_column :sequence_mutations, :magnitude, :integer, :limit => 3
  end

  def self.down
    change_column :user_countries, :level, :string, :default => "'--- :editor\n'"

    change_column :sequence_mutations, :description, :string
    change_column :sequence_mutations, :magnitude, :integer
  end
end
