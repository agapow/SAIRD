class UserLevels < ActiveRecord::Migration
  def self.up
    drop_table :task_assignments

    add_column :user_countries, :level, :string, :default => :editor
  end

  def self.down
    remove_column :user_countries, :level

    create_table "task_assignments", :force => true do |t|
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "user_id"
    end

    add_index "task_assignments", ["user_id"], :name => "index_task_assignments_on_user_id"
  end
end
