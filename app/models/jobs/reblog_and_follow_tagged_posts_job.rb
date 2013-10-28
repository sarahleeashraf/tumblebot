class Jobs::ReblogAndFollowTaggedPostsJob
  def initialize(reqeue = false)
    @requeue = reqeue
  end

  def perform
    Blog.all.each do |blog|
      blog.tags.each do |tag|
        posts = blog.get_tagged_posts(tag.value, 'photo')
        blog.follow_post_users(posts)
        blog.reblog_posts posts
        blog.clean_queue
      end
      blog.reblog_tagged_posts_from_dashboard if blog.tumblr_client.info['user']['following'] > 100
      blog.clean_queue
    end

    Delayed::Job.enqueue(Jobs::ReblogAndFollowTaggedPostsJob.new(true), 0, Time.now + 6.hours) if @requeue

  end
end