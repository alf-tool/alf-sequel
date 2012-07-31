require 'spec_helper'
module Alf
  module Sequel
    describe Relvar, 'delete' do

      before do
        @db = names_db
      end

      subject { relvar.delete(predicate) }

      after do
        @db.disconnect if @db
      end

      context 'on a restriction on Jones' do
        let(:relvar)   { @db.relvar{ (restrict names, :name => "Jones") } }
        let(:predicate){ Predicate.tautology }

        it 'updates the tuples' do
          subject.should eq(1)
          resulting = @db.query{ project(names, [:name]) }
          expected  = supplier_names_relation.minus(Relation(:name => "Jones"))
          resulting.should eq(expected)
        end
      end

    end
  end
end