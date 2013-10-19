class Post < ActiveRecord::Base
  belongs_to :blog

  validates_presence_of :blog, :external_id, :reblog_key
end
