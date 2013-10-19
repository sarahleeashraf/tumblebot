class AddSinceIdToTags < ActiveRecord::Migration
  def change
    add_column :tags, :since_id, :integer, limit: 8
  end
end
