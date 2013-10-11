class Jobs::ReblogAndFollowTaggedPostsJob
  def initialize(reqeue)
    @requeue = reqeue
  end

  def perform
    Blog.all.each do |blog|
      blog.tags.each do |tag|
        posts = blog.get_tagged_posts(tag.value, 'photo')
        posts = blog.remove_already_blogged_posts(posts)
        blog.reblog_posts posts
        blog.follow_post_users(posts)
        blog.clean_queue
      end
    end

    Delayed::Job.enqueue(Jobs::ReblogAndFollowTaggedPostsJob.new(true), 0, run_at: Time.now + 6.hours) if @requeue

  end
end