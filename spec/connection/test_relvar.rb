require 'spec_helper'
module Alf
  module Sequel
    describe Connection, 'relvar' do

      it "should serve relvars" do
        sap.relvar(:suppliers).should be_a(Alf::Relvar)
      end

      it "should be the correct relation" do
        sap.relvar(:suppliers).value.size.should eq(5)
      end

      it 'raises a NoSuchRelvarError if not found' do
        lambda{
          sap.relvar(:nosuchone)
        }.should raise_error
      end

    end
  end
end
