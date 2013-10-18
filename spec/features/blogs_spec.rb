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
    before(:each){ page.driver.browser.basic_authorize('admin','password')}

    it "should update the blog"
    it "should not add duplicate tags" do
      blog.tags << FactoryGirl.build(:tag)

      visit edit_blog_path(blog)
      save_and_open_page
      click_button 'Update Blog'
      save_and_open_page
    end
  end
end