require 'spec_helper'
module Alf
  module Sequel
    describe Relvar, 'where' do

      let(:relvar){
        create_names_schema(sequel_names_adapter)
      }

      subject{ relvar.where(:name => 'Jones') }

      it 'returns another relation variable' do
        subject.should be_a(Relvar)
      end

      it 'returns a relvar with the expected value' do
        expected = supplier_names_relation.restrict(:name => "Jones")
        expected = expected.project([:name])
        subject.value.project([:name]).should eq(expected)
      end

    end
  end
end
