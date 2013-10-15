require "spec_helper"
module Alf
  module Sequel
    module UnitOfWork
      describe Update, "run" do

        let(:conn){ sap_memory.adapter_connection }
        let(:uow){
          UnitOfWork::Update.new(conn, relvar_name, updating, predicate)
        }
        let(:updating){ {status: 55} }
        subject{ uow.run }

        before do
          subject.should be(uow)
        end

        context 'when predicate is a tautology' do
          let(:relvar_name){ :suppliers }
          let(:predicate){ Predicate.tautology }

          it 'updates all tuples' do
            conn.dataset(relvar_name).where(status: 55).to_a.size.should eq(5)
          end
        end

        context 'when predicate is not a tautology' do
          let(:relvar_name){ :suppliers }
          let(:predicate){ Predicate.eq(sid: "S1") }

          it 'removes only targetted tuples' do
            conn.dataset(relvar_name).where(status: 55).to_a.size.should eq(1)
          end
        end

      end
    end # module UnitOfWork
  end # module Sequel
end # module Alf
