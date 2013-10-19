class BlogsController < ApplicationController
  before_action :set_blog, only: [:show, :edit, :update, :destroy]

  # GET /blogs
  def index
    @blogs = Blog.all
  end

  # GET /blogs/1
  def show
  end

  def authorize
    key = TumblrConfig.consumer_key
    secret = TumblrConfig.consumer_secret
    site = TumblrConfig.site

    consumer = OAuth::Consumer.new(key, secret,
                                   { :site => site,
                                     :request_token_path => '/oauth/request_token',
                                     :authorize_path => '/oauth/authorize',
                                     :access_token_path => '/oauth/access_token',
                                     :http_method => :post } )

    request_token = consumer.get_request_token(oauth_callback: new_blog_url)

    logger.info request_token

    session[:request_token] = request_token

    #2. have the user authorize
    redirect_to request_token.authorize_url
  end

  # GET /blogs/new
  def new
    return redirect_to authorize_blogs_url if session[:request_token].nil?

    begin
      @access_token = session[:request_token].get_access_token(oauth_verifier: params[:oauth_verifier])
    rescue => e
      flash[:error] = e.to_s
      return
    end


    @blog = Blog.new(
        access_token: @access_token.token,
        access_token_secret: @access_token.secret,
    )

    user_info = @blog.tumblr_client.info['user']

    @blog.user_name = user_info['name']
  end


  # GET /blogs/1/edit
  def edit
  end


  # POST /blogs
  def create
    @blog = Blog.new(blog_params)
    if @blog.save
      redirect_to @blog, notice: 'Blog was successfully created.'
    else
      render action: 'new'
    end
  end

  # PATCH/PUT /blogs/1
  def update
    if @blog.update(blog_params)
      redirect_to @blog, notice: 'Blog was successfully updated.'
    else
      render action: 'edit'
    end
  end

  # DELETE /blogs/1
  def destroy
    @blog.destroy
    redirect_to blogs_url, notice: 'Blog was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_blog
      @blog = Blog.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def blog_params
      params.require(:blog).permit(:user_name, :hostname, :access_token, :access_token_secret, tags_attributes: [:value, :id])
    end
end
