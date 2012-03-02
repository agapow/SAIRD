class ShortMutationWithMagnitude < ActiveRecord::Migration
  def self.up
    change_column :user_countries, :level, :string, :limit => 255, :default => :editor

    add_column :sequence_mutations, :magnitude, :integer
    change_column :sequence_mutations, :description, :string, :limit => 255
  end

  def self.down
    change_column :user_countries, :level, :string, :default => "'--- :editor\n'"

    remove_column :sequence_mutations, :magnitude
    change_column :sequence_mutations, :description, :text
  end
end
