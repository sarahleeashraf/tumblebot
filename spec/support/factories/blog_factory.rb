require 'factory_girl'

FactoryGirl.define do
  factory :blog do
    user_name                'versaceversaceversaceversace'
    hostname            'versace.tumblr.com'
    access_token        'access_token'
    access_token_secret 'access_token_secret'
  end
end