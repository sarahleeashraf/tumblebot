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

        if blog.tumblr_client.info['user']['following'] > 60
          blog.tags.each do |tag|
            posts = tag.get_tagged_posts_from_dashboard
            blog.reblog_posts posts
          end
        end

        blog.clean_queue
      end
    end

    Delayed::Job.enqueue(Jobs::ReblogAndFollowTaggedPostsJob.new(true), 0, Time.now + 6.hours) if @requeue

  end
end