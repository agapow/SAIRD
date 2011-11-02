class AddedVirusAndCountryRelationsToSuspReport < ActiveRecord::Migration
  def self.up
    add_column :susceptibilities, :country_id, :integer
    add_column :susceptibilities, :virus_type_id, :integer

    add_index :susceptibilities, [:country_id]
    add_index :susceptibilities, [:virus_type_id]
  end

  def self.down
    remove_column :susceptibilities, :country_id
    remove_column :susceptibilities, :virus_type_id

    remove_index :susceptibilities, :name => :index_susceptibilities_on_country_id rescue ActiveRecord::StatementInvalid
    remove_index :susceptibilities, :name => :index_susceptibilities_on_virus_type_id rescue ActiveRecord::StatementInvalid
  end
end
