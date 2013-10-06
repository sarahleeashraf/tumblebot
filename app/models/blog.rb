class Blog < ActiveRecord::Base
  validates_presence_of :user_name, :hostname, :access_token, :access_token_secret
  validates_uniqueness_of :hostname

  def tumblr_client
    @tumblr_client ||= initialize_tumblr_client
  end

  def users_other_blogs
    tumblr_client.info['user']['blogs'].collect{|b| b['url']}
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
