require 'spec_helper'
module Alf
  module Sequel
    describe Connection, 'keys' do

      context "when only a primary key" do
        subject{ sap_connection.keys(:parts) }

        let(:expected){ Keys[ [:pid] ] }

        it{ should eq(expected) }
      end

      context "when both primary key and unique index" do
        subject{ sap_connection.keys(:suppliers) }

        let(:expected){ Keys[ [:sid], [:name] ] }

        it{ should eq(expected) }
      end

    end
  end
end
