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
      expect(blog.users_other_blogs).to eq ["v3rsac3v3rsac3.tumblr.com"]
    end
  end

  describe 'get_tagged_posts' do
    context 'when no type is passed' do
      it 'should return everything that tumblr client returns' do
        Tumblr::Client.any_instance.stub(:tagged).and_return("POSTS")
        expect(blog.get_tagged_posts("tag")).to eq "POSTS"
      end
    end

    context "when type is passed" do
      it "should filter out everything that doesn't have that type" do
        Tumblr::Client.any_instance.stub(:tagged).and_return([{'id' => 2345, 'type' => 'photo'}, {'id' => 4567, 'type' => 'text'}])
        expect(blog.get_tagged_posts("tag",'photo')).to eq [{'id' => 2345, 'type' => 'photo'}]
      end
    end
  end

  describe 'reblog_posts' do
    context 'when no options are passed' do
      it "should reblog the posts with the same tags" do
        Tumblr::Client.any_instance.should_receive(:reblog).with(blog.hostname, {id: 111, reblog_key: '123', state: 'queue', tags: ['tag']})
        blog.reblog_posts([{id: 111, reblog_key: '123', state: 'queue', tags: ['tag'] }.stringify_keys])
      end
    end

    context 'when options are passed' do
      it "should choose the appropriate options based on prescedence"
    end
  end

  describe 'follow_post_users' do
    it "should follow the blogs of the posts" do
      Tumblr::Client.any_instance.should_receive(:follow).with('http://www.google.com')

      blog.follow_post_users([{'post_url' => 'http://www.google.com'}])
    end
  end
end