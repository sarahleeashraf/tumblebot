class AddExcludeToTags < ActiveRecord::Migration
  def change
    add_column :tags, :exclude, :boolean
  end
end
