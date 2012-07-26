require 'spec_helper'
module Alf
  module Sequel
    describe Connection, 'base_relvar' do

      let(:rel) {
        Alf::Relation[
          {:sid => 'S1', :name => 'Smith', :status => 20, :city => 'London'},
          {:sid => 'S2', :name => 'Jones', :status => 10, :city => 'Paris'},
          {:sid => 'S3', :name => 'Blake', :status => 30, :city => 'Paris'},
          {:sid => 'S4', :name => 'Clark', :status => 20, :city => 'London'},
          {:sid => 'S5', :name => 'Adams', :status => 30, :city => 'Athens'}
        ]
      }

      let(:adapter) { sequel_adapter }

      it "should serve relvars" do
        adapter.base_relvar(:suppliers).should be_a(Alf::Relvar)
      end

      it "should be the correct relation" do
        adapter.base_relvar(:suppliers).value.should eq(rel)
      end

      it 'raises a NoSuchRelvarError if not found' do
        lambda{
          adapter.base_relvar(:nosuchone)
        }.should raise_error(NoSuchRelvarError)
      end

    end
  end
end
