require 'spec_helper'

describe Tag do
  describe 'assocaitions' do
    it { should belong_to :blog }
  end

  describe 'validations' do
    it { should validate_presence_of :blog }
    it { should validate_presence_of :value}
  end
end