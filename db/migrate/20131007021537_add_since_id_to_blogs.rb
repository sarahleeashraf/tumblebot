class AddSinceIdToBlogs < ActiveRecord::Migration
  def change
    add_column :blogs, :since_id, :integer, limit: 8
  end
end
