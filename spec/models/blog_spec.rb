require 'spec_helper'

describe Blog do
  let(:blog) { FactoryGirl.build(:blog) }
  describe "associations" do
    it { should have_many :tags }
    it { should have_many :posts}
  end

  describe "validations" do
    it { should validate_presence_of :user_name }
    it { should validate_presence_of :hostname }
    it { should validate_presence_of :access_token }
    it { should validate_presence_of :access_token_secret }
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
        expect(blog.get_tagged_posts("tag", 'photo')).to eq [{'id' => 2345, 'type' => 'photo'}]
      end
    end
  end

  describe 'reblog_posts' do
    let(:blog) { FactoryGirl.create(:blog)}
    context 'when no options are passed' do
      it "should reblog the posts with the same tags" do
        Tumblr::Client.any_instance.should_receive(:reblog).with(blog.hostname, {id: 111, reblog_key: '123', state: 'queue', tags: ['tag']}).and_return({'id' => 123})
        blog.reblog_posts([{id: 111, reblog_key: '123', state: 'queue', tags: ['tag']}.stringify_keys])
      end
    end

    context 'when options are passed' do
      it "should choose the appropriate options based on prescedence"
    end
  end

  describe 'reblog post' do
    let(:blog) { FactoryGirl.create(:blog)}

    it 'should reblog post on tumblr' do
      blog.tumblr_client.should_receive(:reblog).with(blog.hostname, id: 123, reblog_key: '123').and_return({'id' => 456})
      blog.reblog_post({'id' => 123, 'reblog_key' => '123'})
    end

    context "when the reblog is successful" do
      it "should create a post" do
        blog.tumblr_client.stub(:reblog).and_return({'id' => 456})
        expect {
          blog.reblog_post({'id' => 123, 'reblog_key' => '123'})
        }.to change { Post.count }.from(0).to(1)

        expect(Post.last.external_id).to eq 456

      end
    end

    context "when the reblog is not successful" do
      it "should raise exception" do
        blog.tumblr_client.stub(:reblog).and_return({"status"=>400, "msg"=>"Bad Request", "error"=>"Invalid id or reblog_key specified."})
        expect {
          blog.reblog_post({'id' => 123, 'reblog_key' => '123'})
        }.to raise_error(Blog::ReblogFailed)

      end
    end

  end

  describe 'follow_post_users' do
    it "should follow the blogs of the posts" do
      Tumblr::Client.any_instance.should_receive(:follow).with('http://www.google.com')

      blog.follow_post_users([{'post_url' => 'http://www.google.com'}])
    end
  end

  describe 'remove_already_blogged_posts' do
    context "when the blog as already been reblogged" do
      it "should remove it from the array" do
        blog.stub(:reblogged_already?).and_return(true)
        expect(blog.remove_already_blogged_posts([{'note_count' => 99}])).to eq []
      end
    end

    context "when the blog hasn't been reblogged" do
      it "should leave it in the array" do
        blog.stub(:reblogged_already?).and_return(false)
        expect(blog.remove_already_blogged_posts([{'note_count' => 99}])).to eq [{'note_count' => 99}]

      end
    end
  end

  describe 'reblogged_already?' do
    context "when this post has already been reblogged on this blog" do
      it "should return true" do
        Post.create(blog: blog, external_id: 1234567, reblog_key: '12345')
        post = {'id' => '1234567', 'post_url' => 'http://missingtheambitiousgene.tumblr.com/image/63684588512', 'reblog_key' => '12345'}

        expect(blog.reblogged_already?(post)).to eq true
      end
    end

    context "when this post has not been reblogged on this blog" do
      it "should return false" do
        post = {'id' => '1234567', 'post_url' => 'http://missingtheambitiousgene.tumblr.com/image/63684588512', 'reblog_key' => '12345'}

        expect(blog.reblogged_already?(post)).to eq false

      end
    end
  end

  describe 'clean_queue' do
    it "should edit the post with the passed caption" do
      blog.tumblr_client.should_receive(:edit).with(blog.hostname, {id: 61748593713, caption: 'hello_world'})

      blog.clean_queue(caption: 'hello_world')
    end
  end

  describe 'reblog_tagged_posts_from_dashboard' do
    let(:blog) { FactoryGirl.create(:blog)}

    it "should update the since id on the blog for every loop" do
      expect(blog).to receive(:update_attributes).with(since_id: 65276229696)
      expect(blog).to receive(:update_attributes).with(since_id: 65276229800)

      blog.reblog_tagged_posts_from_dashboard
    end

    context "when the post has one of the blog's tags" do
      before(:each){ blog.tags.create(value: 'Miu Miu') }

      context "when the post has already been reblogged" do
        before(:each){blog.posts.create(external_id: 1, reblog_key: 'uICFuSOo')}

        it "should not reblog the post" do
          blog.tumblr_client.should_not_receive(:reblog)
          blog.reblog_tagged_posts_from_dashboard
        end

        it "should not count as one of the reblogged posts" do
          blog.tumblr_client.should_receive(:dashboard).exactly(3).times.and_call_original
          blog.reblog_tagged_posts_from_dashboard(1)
        end
      end

      context "when the post hasn't been reblogged already" do
        it "should reblog the post" do
          blog.tumblr_client.should_receive(:reblog).with('versace.tumblr.com', id: 65276094097, reblog_key: 'uICFuSOo', tags: ["Fashion", "Miu Miu", "Runway", "Details"], state: 'queue').and_return('id' => 10)
          blog.reblog_tagged_posts_from_dashboard
        end

        it "should reblog the number of posts passed" do
          blog.tumblr_client.stub(:reblog).and_return('id' => 10)
          blog.tumblr_client.should_receive(:dashboard).once.and_call_original
          blog.reblog_tagged_posts_from_dashboard(1)
        end
      end
    end

    context "when the post doesn't have one of the blog tags" do
      it "should not reblog" do
        blog.should_not_receive(:reblog)
        blog.reblog_tagged_posts_from_dashboard
      end
    end
  end
end