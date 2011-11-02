class OddDropOfSuspEntry < ActiveRecord::Migration
  def self.up
    add_column :susceptibilities, :na_sequence_aa, :string
    add_column :susceptibilities, :ha_sequence_aa, :string
    add_column :susceptibilities, :m2_sequence_aa, :string
  end

  def self.down
    remove_column :susceptibilities, :na_sequence_aa
    remove_column :susceptibilities, :ha_sequence_aa
    remove_column :susceptibilities, :m2_sequence_aa
  end
end
