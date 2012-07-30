require 'spec_helper'
module Alf
  module Sequel
    describe Connection, 'native_schema_def' do

      subject{ sap_connection.native_schema_def }

      it{ should be_a(::Alf::Database::SchemaDef) }

      it "has the expected methods" do
        lambda{
          subject.instance_method(:suppliers)
          subject.instance_method(:parts)
          subject.instance_method(:supplies)
        }.should_not raise_error(NameError)
      end

    end
  end
end
