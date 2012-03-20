class WeirdSeqMutationLimitThatDidntGetSet < ActiveRecord::Migration
  def self.up
    change_column :sequence_mutations, :magnitude, :integer, :limit => 3

    change_column :user_countries, :level, :string, :limit => 255, :default => :editor
  end

  def self.down
    change_column :sequence_mutations, :magnitude, :integer

    change_column :user_countries, :level, :string, :default => "--- :editor\n"
  end
end
