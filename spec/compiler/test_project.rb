require 'compiler_helper'
module Alf
  module Sequel
    describe Compiler, "project" do

      subject{ compile(expr) }

      context 'when the operand is fully compilable' do
        let(:expr){ project(suppliers, [:sid, :name]) }

        specify{
          subject.sql.should eq("SELECT `t1`.`sid`, `t1`.`name` FROM `suppliers` AS 't1'")
        }
      end

      context 'when the operand is fully compilable (distinct needed)' do
        let(:expr){ project(suppliers, [:city]) }

        specify{
          subject.sql.should eq("SELECT DISTINCT `t1`.`city` FROM `suppliers` AS 't1'")
        }
      end

      context 'when the operand is a restriction on a key part' do
        let(:expr){ project(restrict(supplies, Predicate.eq(:sid, 1)), [:pid]) }

        specify{
          subject.sql.should eq("SELECT `t1`.`pid` FROM `supplies` AS 't1' WHERE (`t1`.`sid` = 1)")
        }
      end

      context 'when the operand is a restriction on the key' do
        let(:expr){ project(restrict(suppliers, Predicate.eq(:sid, 1)), [:sid]) }

        specify{
          subject.sql.should eq("SELECT `t1`.`sid` FROM `suppliers` AS 't1' WHERE (`t1`.`sid` = 1)")
        }
      end

      context 'when the operand is fully compilable (allbut, distinct)' do
        let(:expr){ project(suppliers, [:sid, :name, :status], :allbut => true) }

        specify{
          subject.sql.should eq("SELECT DISTINCT `t1`.`city` FROM `suppliers` AS 't1'")
        }
      end

      context 'when the operand is a renaming' do
        let(:expr){ project(rename(suppliers, :sid => :supplier_id), [:supplier_id]) }

        specify{
          subject.sql.should eq("SELECT `t2`.`supplier_id` AS 'supplier_id' FROM (SELECT `t1`.`sid` AS 'supplier_id', `t1`.`name` AS 'name', `t1`.`status` AS 'status', `t1`.`city` AS 'city' FROM `suppliers` AS 't1') AS 't2'")
        }
      end

      context 'when the operand is not compilable' do
        let(:expr){ project(an_operand, [:sid, :name]) }

        it{ should be_a(Engine::Cog) }
      end

    end
  end
end