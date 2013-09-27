require 'spec_helper'
module Alf
  module Sequel
    describe Connection, 'heading' do

      subject{ sap.heading(:suppliers) }

      let(:expected){
        Heading[:sid => String, :name => String, :status => Integer, :city => String]
      }

      it{ should eq(expected) }

    end
  end
end
