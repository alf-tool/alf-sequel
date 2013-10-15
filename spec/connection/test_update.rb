require 'spec_helper'
module Alf
  module Sequel
    describe Connection, 'update' do

      let(:conn){ sap_memory }

      subject{ conn.update(:suppliers, {status: 10}, Predicate.tautology) }

      it 'returns a UnitOfWork::Update' do
        subject.should be_a(UnitOfWork::Update)
      end

      it 'is ran' do
        subject.should be_ran
      end

    end
  end
end
