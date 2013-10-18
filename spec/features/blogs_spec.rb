require 'spec_helper'

describe BlogsController do
  let(:blog) { FactoryGirl.create(:blog)}
  describe 'index' do
    it "should require basic auth" do
      visit blogs_path
      expect(page).to have_content('HTTP Basic: Access denied.')
    end

    it "should be successful" do
      page.driver.browser.basic_authorize('admin','password')
      visit blogs_path
      expect(page).to have_content('Listing blogs')
    end
  end

  describe "update" do
    it "should update the blog" do
      visit edit_blog_path(blog)
      #save_and_open_page
    end
  end
end