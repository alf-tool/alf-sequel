require 'spec_helper'
module Alf
  module Sequel
    describe Relvar, 'update' do

      before do
        @db = names_db
      end

      after do
        @db.disconnect if @db
      end

      after do
        resulting = @db.query{ project(names, [:name]) }
        expected  = supplier_names_relation.
                      minus(Relation(:name => "Jones")).
                      union(Relation(:name => "JONES"))
        resulting.should eq(expected)
      end

      let(:updating){ {:name => "JONES"} }

      context 'with a filtering predicate' do
        let(:relvar){ @db.relvar(:names) }
        subject {
          relvar.update(updating, Predicate.eq(:name => "Jones"))
        }

        it 'updates the relvar' do
          subject
        end
      end

      context 'on a restricted relvar' do
        let(:relvar){ @db.relvar{ (restrict names, :name => "Jones") } }
        subject {
          relvar.update({:name => "JONES"})
        }

        it 'updates the relvar' do
          subject
        end
      end

    end
  end
end