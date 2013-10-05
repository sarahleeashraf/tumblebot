require 'spec_helper'

describe Blog do
  describe "validations" do
    it { should validate_presence_of :name }
    it { should validate_presence_of :hostname }
    it { should validate_presence_of :access_token }
    it { should validate_presence_of :access_token_secret}
  end
end