require 'spec_helper'
module Alf
  module Sequel
    describe Compiler, "when joining relvars" do

      def conn
        @conn ||= Alf::Test::Sap.connect
      end

      after(:each) do
        conn.adapter_connection.close!
      end

      it 'should not mix the range var names' do
        left   = conn.relvar{ project(suppliers, [:sid]) }
        right  = conn.relvar{ project(suppliers, [:sid]) }
        joined = left.join(right)
        joined.to_a
      end

    end
  end
end
