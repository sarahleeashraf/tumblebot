class Tag < ActiveRecord::Base
  belongs_to :blog

  validates_presence_of :blog, :value

  def get_tagged_posts_from_dashboard(count = 20)
    dashboard_since_id = since_id || 1
    tagged_posts = []

    begin
      response = blog.tumblr_client.dashboard(since_id: dashboard_since_id)

      break if response['posts'].nil?
      dashboard_posts = response['posts']
      dashboard_posts.each do |post|
        tagged_posts << post if post['tags'].include?(value)
      end

      dashboard_since_id = dashboard_posts.first['id']

      logger.info tagged_posts.size
      logger.info  dashboard_posts.first['date']

    end while (tagged_posts.size < count and !dashboard_posts.empty?)

    self.update_attributes(since_id: dashboard_since_id)
    tagged_posts

  end

end
