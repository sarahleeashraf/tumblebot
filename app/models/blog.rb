class Blog < ActiveRecord::Base
  has_many :tags, inverse_of: :blog, dependent: :destroy
  has_many :posts, inverse_of: :blog

  validates_presence_of :user_name, :hostname, :access_token, :access_token_secret
  validates_uniqueness_of :hostname

  accepts_nested_attributes_for :tags, reject_if: proc { |attributes| attributes['value'].blank? }, allow_destroy: true

  class ReblogFailed < StandardError; end;

  def tumblr_client
    @tumblr_client ||= initialize_tumblr_client
  end

  def get_tagged_posts(tag, type = nil)
    posts = tumblr_client.tagged(tag, limit: 20)
    posts = posts.collect{|post| post if post['type'] == type }.compact unless type.nil?
    posts
  end

  def follow_post_users(posts)
    posts.each do |post|
      tumblr_client.follow(post['post_url'])
    end
  end

  def reblog_posts(posts, options = {})
    posts.each do |post|
      params = {state: 'queue', tags: post['tags']}.merge(options)
      reblog_post(post, params)
    end
  end

  def reblog_post(post, params = {})
    return if reblogged_already? post
    result = tumblr_client.reblog(hostname, params.merge({id: post['id'], reblog_key: post['reblog_key']}))

    if !result['id'].nil?
      self.posts.create(external_id: result['id'], reblog_key: post['reblog_key'])
    else
      raise ReblogFailed.new result['error']
    end
  end

  def remove_already_blogged_posts(posts)
    posts.collect do |post|
      post unless reblogged_already?(post)
    end.compact
  end

  def reblogged_already?(post)
    posts.reload
    posts.collect(&:reblog_key).include?(post['reblog_key'])
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
