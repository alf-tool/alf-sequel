require "spec_helper"
module Alf
  module Sequel
    module UnitOfWork
      describe Insert, "run" do

        let(:conn){ sap_memory.adapter_connection }
        let(:uow){
          UnitOfWork::Insert.new(conn, relvar_name, tuples)
        }
        subject{ uow.run }

        before do
          subject.should be(uow)
        end

        context 'when the primary key is not composite' do
          let(:relvar_name){ :suppliers }

          context 'with only one tuple' do
            let(:tuples){ [{sid: 'S10', name: "Marcus", city: "Ouagadougou", status: 55}] }

            it "inserts the tuple" do
              conn.dataset(:suppliers).where(sid: "S10").should_not be_empty
            end

            it 'keeps information about inserted tuples' do
              puts uow.matching_relation
              uow.matching_relation.should eq(Relation sid: 'S10')
            end
          end

          context 'with multiple tuples' do
            let(:tuples){ [
              {sid: "S10", name: "Marcus", city: "Ouagadougou", status: 55},
              {sid: "S11", name: "Demete", city: "Albertville", status: 56}
            ]}

            it "inserts the tuples" do
              conn.dataset(:suppliers).where(sid: "S10").should_not be_empty
              conn.dataset(:suppliers).where(sid: "S11").should_not be_empty
            end

            it 'keeps information about inserted tuples' do
              uow.matching_relation.should eq(Relation sid: ["S10", "S11"])
            end
          end
        end

        context 'when the primary key is composite' do
          let(:relvar_name){ :supplies }

          let(:tuples){ [
            {sid: "S5", pid: "P1"},
            {sid: "S5", pid: "P2"}
          ]}

          it "inserts the tuples" do
            conn.dataset(:supplies).where(sid: "S5").to_a.size.should eq(2)
          end

          it 'keeps information about inserted tuples' do
            uow.matching_relation.should eq(Relation(tuples))
          end
        end

      end
    end # module UnitOfWork
  end # module Sequel
end # module Alf
