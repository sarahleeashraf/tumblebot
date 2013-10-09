require 'spec_helper'

describe BlogsController do
  let(:blog) { FactoryGirl.create(:blog)}
  describe "update" do
    it "should update the blog" do
      visit edit_blog_path(blog)
      #save_and_open_page
    end
  end
end