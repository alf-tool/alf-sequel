require 'spec_helper'
module Alf
  module Sequel
    describe Connection, 'delete' do

      let(:conn){ sap_memory }

      subject{ conn.delete(:suppliers, Predicate.tautology) }

      it 'returns a UnitOfWork::Delete' do
        subject.should be_a(UnitOfWork::Delete)
      end

      it 'is ran' do
        subject.should be_ran
      end

    end
  end
end
