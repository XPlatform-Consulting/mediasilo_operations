class CreateMediasiloOperations < ActiveRecord::Migration
  def self.up
    create_table :action_mediasilo_operations do |t|
      t.string   :name
      t.text     :comments

      t.string   :operation
      t.string   :hostname
      t.string   :username
      t.string   :password
      
      t.string   :source_file_path
      t.string   :project_name
      t.string   :folder_name

      t.timestamps
    end
  end

  def self.down
    drop_table :action_mediasilo_operations
  end
end