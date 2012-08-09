require 'spec_helper'
module Alf
  module Sequel
    describe Connection, 'native_schema_def' do

      subject{ sap_connection.native_schema_def }

      it{ should be_a(::Alf::Database::SchemaDef) }

      it "has the expected methods" do
        subject.relvars.should have_key(:suppliers)
        subject.relvars.should have_key(:parts)
        subject.relvars.should have_key(:supplies)
      end

    end
  end
end
