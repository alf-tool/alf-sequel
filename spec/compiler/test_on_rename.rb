require 'compiler_helper'
module Alf
  module Sequel
    describe Compiler, "rename" do

      subject{ compile(expr) }

      context 'when the operand is fully compilable' do
        let(:expr){ rename(:suppliers, :sid => :id) }

        specify{
          subject.sql.should eq("SELECT `sid` AS 'id', `name` AS 'name', `status` AS 'status', `city` AS 'city' FROM `suppliers`")
        }
      end

    end
  end
end