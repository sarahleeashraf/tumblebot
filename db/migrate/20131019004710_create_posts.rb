class CreatePosts < ActiveRecord::Migration
  def change
    create_table :posts do |t|
      t.integer :external_id, limit: 8
      t.string :reblog_key
      t.integer :blog_id

      t.timestamps
    end
  end
end
