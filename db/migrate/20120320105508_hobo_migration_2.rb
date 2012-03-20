class HoboMigration2 < ActiveRecord::Migration
  def self.up
    change_column :user_countries, :level, :string, :limit => 255, :default => :editor

    add_index :sequence_mutations, [:susceptibility_sequence_id]
  end

  def self.down
    change_column :user_countries, :level, :string, :default => "'--- :editor\n'"

    remove_index :sequence_mutations, :name => :index_sequence_mutations_on_susceptibility_sequence_id rescue ActiveRecord::StatementInvalid
  end
end
