require 'compiler_helper'
module Alf
  module Sequel
    describe Compiler, "rename" do

      subject{ compile(expr) }

      context 'when the operand is fully compilable' do
        let(:expr){ rename(suppliers, :sid => :id) }

        specify{
          subject.sql.should eq("SELECT `t1`.`sid` AS 'id', `t1`.`name` AS 'name', `t1`.`status` AS 'status', `t1`.`city` AS 'city' FROM `suppliers` AS 't1'")
        }
      end

    end
  end
end