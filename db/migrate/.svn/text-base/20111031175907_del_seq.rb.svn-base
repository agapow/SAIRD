class DelSeq < ActiveRecord::Migration
  def self.up
    drop_table :sequences

    change_column :user_countries, :level, :string, :limit => 255, :default => :editor
  end

  def self.down
    change_column :user_countries, :level, :string, :default => "'--- :editor\n'"

    create_table "sequences", :force => true do |t|
      t.integer "susceptibility_id"
      t.string  "title"
      t.integer "gene_id"
    end

    add_index "sequences", ["gene_id"], :name => "index_sequences_on_gene_id"
    add_index "sequences", ["susceptibility_id"], :name => "index_sequences_on_susceptibility_id"
  end
end
