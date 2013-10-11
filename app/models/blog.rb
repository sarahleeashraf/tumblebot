class Blog < ActiveRecord::Base
  has_many :tags, inverse_of: :blog, dependent: :destroy

  validates_presence_of :user_name, :hostname, :access_token, :access_token_secret
  validates_uniqueness_of :hostname

  accepts_nested_attributes_for :tags, reject_if: proc { |attributes| attributes['value'].blank? }, allow_destroy: true

  def tumblr_client
    @tumblr_client ||= initialize_tumblr_client
  end

  def get_tagged_posts(tag, type = nil)
    posts = tumblr_client.tagged(tag, limit: 20)
    posts = posts.collect{|post| post if post['type'] == type }.compact unless type.nil?
    posts
  end

  def get_tagged_posts_from_dashboard(tag, type: nil, count: 20)
    dashboard_since_id = since_id || 63069378767
    tagged_posts = []

    dashboard_tags = {}
    begin
      dashboard_posts = tumblr_client.dashboard(since_id: dashboard_since_id)['posts']
      dashboard_posts.each do |post|
        post['tags'].each do |tag|
          if dashboard_tags[tag].nil?
            dashboard_tags[tag] = 1
          else
            dashboard_tags[tag] += 1
          end
        end

        tagged_posts << post if post['tags'].include?(tag)
      end


      dashboard_since_id = dashboard_posts.last['id']

    end while (tagged_posts.size < count and !dashboard_posts.empty?)

    self.update_attributes(since_id: dashboard_since_id)
    tagged_posts

  end

  def follow_post_users(posts)
    posts.each do |post|
      tumblr_client.follow(post['post_url'])
    end
  end

  def reblog_posts(posts, options = {})
    posts.each do |post|
      params = {state: 'queue', tags: post['tags']}.merge(options)
      tumblr_client.reblog(hostname, params.merge({id: post['id'], reblog_key: post['reblog_key']}))
    end
  end

  def remove_already_blogged_posts(posts)
    posts.collect do |post|
      if post['note_count'] == 0
        post
      else
        post unless reblogged_already?(post)
      end
    end.compact
  end

  def reblogged_already?(post)
    options = {id: post['id'], notes_info: true, reblog_info: true}
    notes = tumblr_client.posts(URI.parse(post['post_url']).hostname, options )['posts'].first['notes']
    notes.collect{|note| URI.parse(note['blog_url']).hostname }.include? hostname
  end

  def users_other_blogs
    tumblr_client.info['user']['blogs'].collect{|b| URI.parse(b['url']).hostname }
  end

  def clean_queue(options = {caption: ''})
    offset = 0
    begin
      posts_to_clean = tumblr_client.queue(hostname, limit: 20, offset: offset)['posts']
      offset += 20

      posts_to_clean.each do |post|
        next unless post['type'] == 'photo'
        tumblr_client.edit(hostname, options.merge(id: post['id']))
      end
    end while !posts_to_clean.empty?
  end

  private

  def initialize_tumblr_client
    Tumblr.configure do |config|
      config.consumer_key = TumblrConfig.consumer_key
      config.consumer_secret = TumblrConfig.consumer_secret
      config.oauth_token = access_token
      config.oauth_token_secret = access_token_secret
    end

    Tumblr::Client.new
  end
end
