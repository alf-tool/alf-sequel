require 'spec_helper'
describe "assumptions" do

  context 'sqlite://memory' do
    let(:db1){ ::Sequel.connect(sequel_database_memory) }
    let(:db2){ ::Sequel.connect(sequel_database_memory) }

    it 'leads to two different databases' do
      db1.create_table(:blah){ primary_key :id }
      db2.create_table(:blah){ primary_key :id }
    end
  end

end