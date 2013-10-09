class Jobs::ReblogAndFollowTaggedPostsJob
  def perform
    Blog.all.each do |blog|

      blog.tags.each do |tag|
        posts = blog.get_tagged_posts(tag.value, 'photo')
        blog.reblog_posts posts
        blog.follow_post_users(posts)
        blog.clean_queue
      end
    end
  end
end