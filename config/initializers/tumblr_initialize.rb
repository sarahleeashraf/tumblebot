module TumblrConfig
  def self.consumer_key
    @consumer_key ||= ENV['TUMBLR_CONSUMER_KEY']
  end

  def self.consumer_secret
    @consumer_secret ||= ENV['TUMBLR_CONSUMER_SECRET']
  end

  def self.site
    'http://www.tumblr.com'
  end
end
