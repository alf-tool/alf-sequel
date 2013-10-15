require "spec_helper"
module Alf
  module Sequel
    module UnitOfWork
      describe Delete, "run" do

        let(:conn){ sap_memory.adapter_connection }
        let(:uow){
          UnitOfWork::Delete.new(conn, relvar_name, predicate)
        }
        subject{ uow.run }

        before do
          subject.should be(uow)
        end

        context 'when predicate is a tautology' do
          let(:relvar_name){ :suppliers }
          let(:predicate){ Predicate.tautology }

          it 'removes all tuples' do
            conn.dataset(relvar_name).should be_empty
          end
        end

        context 'when predicate is not a tautology' do
          let(:relvar_name){ :suppliers }
          let(:predicate){ Predicate.eq(sid: "S1") }

          it 'removes only targetted tuples' do
            conn.dataset(relvar_name).should_not be_empty
            conn.dataset(relvar_name).where(sid: "S1").should be_empty
          end
        end

      end
    end # module UnitOfWork
  end # module Sequel
end # module Alf
