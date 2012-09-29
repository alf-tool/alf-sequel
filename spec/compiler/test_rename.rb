require 'compiler_helper'
module Alf
  module Sequel
    describe Compiler, "rename" do

      subject{ compile(expr) }

      context 'when the operand is fully compilable' do
        let(:expr){ rename(suppliers, :sid => :id) }

        specify{
          subject.sql.should eq("SELECT * FROM (SELECT `t1`.`sid` AS 'id', `t1`.`name` AS 'name', `t1`.`status` AS 'status', `t1`.`city` AS 'city' FROM `suppliers` AS 't1') AS 't2'")
        }
      end

      context 'when the operand is another renaming' do
        let(:expr){ rename(rename(suppliers, :sid => :id), :id => :foo) }

        specify{
          subject.sql.should eq("SELECT * FROM (SELECT `t2`.`id` AS 'foo', `t2`.`name` AS 'name', `t2`.`status` AS 'status', `t2`.`city` AS 'city' FROM (SELECT `t1`.`sid` AS 'id', `t1`.`name` AS 'name', `t1`.`status` AS 'status', `t1`.`city` AS 'city' FROM `suppliers` AS 't1') AS 't2') AS 't3'")
        }
      end

    end
  end
end