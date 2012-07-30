require 'spec_helper'
module Alf
  module Sequel
    describe Connection, 'native_schema' do

      subject{ sap.native_schema }

      it{ should be_a(::Alf::Database::Schema) }

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
