module WebmockStubs
  def self.stub_all_calls
    WebmockStubs::Stubs.public_instance_methods.each do |method|

      WebmockStubs::Stubs.send method if method =~ /^stub_/
    end
  end

  module Stubs
    extend self

    def stub_tumblr_request_token
      url = 'http://www.tumblr.com/oauth/request_token'
      body = File.new "#{::Rails.root}/spec/support/fixtures/webmock/www.tumblr.com/oauth/request_token"

      WebMock.stub_request(:post, url).to_return({status: 200, headers: {}, body: body})
    end

    def stub_tumblr_user_info
      url = 'http://api.tumblr.com/v2/user/info'
      body = File.new "#{::Rails.root}/spec/support/fixtures/webmock/www.tumblr.com/user/info"

      WebMock.stub_request(:get, url).to_return({status: 200, headers: {'Content-Type' => 'application/json'}, body: body})
    end

    def stub_tumblr_posts_queue
      url = 'http://api.tumblr.com/v2/blog/versace.tumblr.com/posts/queue?limit=20&offset=0?limit=20&offset=0'
      body = File.new "#{::Rails.root}/spec/support/fixtures/webmock/www.tumblr.com/posts/queue?limit=20&offset=0"

      WebMock.stub_request(:get, url).to_return({status: 200, headers: {'Content-Type' => 'application/json'}, body: body})
    end

    def stub_tumblr_posts_queue_page_2
      url = 'http://api.tumblr.com/v2/blog/versace.tumblr.com/posts/queue?limit=20&offset=0?limit=20&offset=20'
      body = File.new "#{::Rails.root}/spec/support/fixtures/webmock/www.tumblr.com/posts/queue?limit=20&offset=20"

      WebMock.stub_request(:get, url).to_return({status: 200, headers: {'Content-Type' => 'application/json'}, body: body})
    end

    def stub_tumblr_dashboard_page
      url = 'http://api.tumblr.com/v2/user/dashboard?since_id=1'
      body = File.new "#{::Rails.root}/spec/support/fixtures/webmock/www.tumblr.com/user/dashboard?since_id=1"

      WebMock.stub_request(:get, url).to_return({status: 200, headers: {'Content-Type' => 'application/json'}, body: body})
    end

    def stub_tumblr_dashboard_page2
      url = 'http://api.tumblr.com/v2/user/dashboard?since_id=65276229696'
      body = File.new "#{::Rails.root}/spec/support/fixtures/webmock/www.tumblr.com/user/dashboard?since_id=65276229696"

      WebMock.stub_request(:get, url).to_return({status: 200, headers: {'Content-Type' => 'application/json'}, body: body})
    end

    def stub_tumblr_dashboard_page3
      url = 'http://api.tumblr.com/v2/user/dashboard?since_id=65276229800'
      body = File.new "#{::Rails.root}/spec/support/fixtures/webmock/www.tumblr.com/user/dashboard?since_id=65276229800"

      WebMock.stub_request(:get, url).to_return({status: 200, headers: {'Content-Type' => 'application/json'}, body: body})
    end
  end
end