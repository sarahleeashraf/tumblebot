module BlogsHelper
  def setup_blog(blog)
    blog.tags.build
    blog
  end
end
