require 'spec_helper'
module Alf
  module Sequel
    describe Connection, "with_connection" do

      let(:adapter){ sequel_adapter }

      def subject(&bl)
        adapter.with_connection(&bl)
      end

      context 'without options' do

        it 'yields a Sequel::Database' do
          subject do |db|
            db.should be_a(::Sequel::Database)
          end
        end

      end

    end
  end
end