require 'spec_helper'

describe Post do
  describe 'associations' do
    it {should belong_to :blog}
  end

  describe 'validations' do
    it { should validate_presence_of :blog }
    it { should validate_presence_of :external_id }
    it { should validate_presence_of :reblog_key }
  end
end
