class CreateBlogs < ActiveRecord::Migration
  def change
    create_table :blogs do |t|
      t.string :name
      t.string :hostname
      t.string :access_token
      t.string :access_token_secret

      t.timestamps
    end
  end
end
