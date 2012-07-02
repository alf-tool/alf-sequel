require 'spec_helper'
module Alf
  describe Sequel do

    it "should have a version number" do
      Sequel.const_defined?(:VERSION).should be_true
    end

  end
end