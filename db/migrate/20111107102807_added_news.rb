class AddedNews < ActiveRecord::Migration
  def self.up
    create_table :news_items do |t|
      t.string   :name
      t.text     :body
      t.datetime :created_at
      t.datetime :updated_at
      t.integer  :poster_id
    end
    add_index :news_items, [:poster_id]

    change_column :user_countries, :level, :string, :limit => 255, :default => :editor
  end

  def self.down
    change_column :user_countries, :level, :string, :default => "'--- :editor\n'"

    drop_table :news_items
  end
end
