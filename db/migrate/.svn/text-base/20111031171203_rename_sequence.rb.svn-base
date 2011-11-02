class RenameSequence < ActiveRecord::Migration
  def self.up
    add_column :mutations, :susceptibility_sequence_id, :integer

    add_column :susceptibility_sequences, :title, :string
    add_column :susceptibility_sequences, :susceptibility_id, :integer
    add_column :susceptibility_sequences, :gene_id, :integer
    remove_column :susceptibility_sequences, :created_at
    remove_column :susceptibility_sequences, :updated_at

    change_column :user_countries, :level, :string, :limit => 255, :default => :editor

    remove_index :mutations, :name => :index_mutations_on_sequence_id rescue ActiveRecord::StatementInvalid
    add_index :mutations, [:susceptibility_sequence_id]

    add_index :susceptibility_sequences, [:susceptibility_id]
    add_index :susceptibility_sequences, [:gene_id]
  end

  def self.down
    remove_column :mutations, :susceptibility_sequence_id

    remove_column :susceptibility_sequences, :title
    remove_column :susceptibility_sequences, :susceptibility_id
    remove_column :susceptibility_sequences, :gene_id
    add_column :susceptibility_sequences, :created_at, :datetime
    add_column :susceptibility_sequences, :updated_at, :datetime

    change_column :user_countries, :level, :string, :default => "'--- :editor\n'"

    remove_index :mutations, :name => :index_mutations_on_susceptibility_sequence_id rescue ActiveRecord::StatementInvalid
    add_index :mutations, [:sequence_id]

    remove_index :susceptibility_sequences, :name => :index_susceptibility_sequences_on_susceptibility_id rescue ActiveRecord::StatementInvalid
    remove_index :susceptibility_sequences, :name => :index_susceptibility_sequences_on_gene_id rescue ActiveRecord::StatementInvalid
  end
end
