require 'spec_helper'
module Alf
  module Sequel
    describe Relvar, 'insert' do

      before do
        @db = names_db
      end

      subject { relvar.insert(tuples) }

      after do
        @db.disconnect if @db
      end

      after do
        resulting = @db.query{ project(names, [:name]) }
        expected  = supplier_names_relation.union Relation(tuples)
        resulting.should eq(expected)
      end

      let(:relvar){ @db.relvar(:names) }

      context 'with a single Hash' do
        let(:tuples){ {:name => "Zurch"} }

        it 'returns a relation with primary keys' do
          subject.should eq(Relation(:id => 6))
        end
      end

      context 'with an iterator of tuples' do
        let(:tuples){ [{:name => "Zurch"}, {:name => "Zurgh"}] }

        it 'returns a relation with primary keys' do
          subject.should eq(Relation(:id => [6, 7]))
        end
      end

    end
  end
end