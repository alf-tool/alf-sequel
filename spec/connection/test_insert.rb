require 'spec_helper'
module Alf
  module Sequel
    describe Connection, 'insert' do

      let(:conn){ sap_memory }

      subject{ conn.insert(:suppliers, suppliers) }

      let(:suppliers){[
        {sid: 10, name: "Marcus", status: 20, city: "Ouagadougou"}
      ]}

      it 'returns a UnitOfWork::Insert' do
        subject.should be_a(UnitOfWork::Insert)
      end

      it 'is ran' do
        subject.should be_ran
      end

    end
  end
end
