class Jobs::ReblogAndFollowTaggedPostsJob
  def initialize(reqeue = false)
    @requeue = reqeue
  end

  def perform
    Blog.all.each do |blog|
      blog.tags.each do |tag|
        posts = blog.get_tagged_posts(tag.value, 'photo')
        blog.follow_post_users(posts)
        posts = blog.remove_already_blogged_posts(posts)
        blog.reblog_posts posts

        blog.tags.each do |tag|
          posts = tag.get_tagged_posts_from_dashboard
          posts = blog.remove_already_blogged_posts(posts)
          blog.reblog_posts posts
        end

        blog.clean_queue
      end
    end

    Delayed::Job.enqueue(Jobs::ReblogAndFollowTaggedPostsJob.new(true), 0, Time.now + 6.hours) if @requeue

  end
end