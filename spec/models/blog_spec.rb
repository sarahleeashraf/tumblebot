require 'spec_helper'

describe Blog do
  let(:blog) { FactoryGirl.build(:blog)}
  describe "associations" do
    it { should have_many :tags}
  end

  describe "validations" do
    it { should validate_presence_of :user_name }
    it { should validate_presence_of :hostname }
    it { should validate_presence_of :access_token }
    it { should validate_presence_of :access_token_secret}
    it { should validate_uniqueness_of :hostname }
  end

  describe 'tumblr_client' do
    it "should return an initialized tumblr client" do
      expect(blog.tumblr_client).to be_instance_of(Tumblr::Client)
    end
  end

  describe 'users_other_blogs' do
    it "should return an array of blogs" do
      expect(blog.users_other_blogs).to eq ["http://v3rsac3v3rsac3.tumblr.com/"]
    end
  end
end