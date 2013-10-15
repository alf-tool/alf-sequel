require 'spec_helper'
module Alf
  module Sequel
    describe Connection, 'lock' do

      subject{ sap.lock(:suppliers, :exclusive){ @seen = true } }

      it 'yields the block' do
        subject
        @seen.should be_true
      end

    end
  end
end
