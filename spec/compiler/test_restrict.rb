require 'compiler_helper'
module Alf
  module Sequel
    describe Compiler, "restrict" do

      subject{ compile(expr) }

      context 'with a native predicate' do
        let(:expr){ restrict(suppliers, proc{ status > 20 }) }
      
        it{ should be_a(Engine::Filter) }
      end
      
      context 'when the operand is fully compilable' do
        let(:expr){ restrict(suppliers, :name => "Jones") }

        specify{
          subject.sql.should eq("SELECT * FROM `suppliers` AS 't1' WHERE (`t1`.`name` = 'Jones')")
        }
      end

      context 'when the operand is a IN (values)' do
        let(:expr){ restrict(suppliers, Predicate.in(:city, ["London", "Paris"])) }

        specify{
          subject.sql.should eq("SELECT * FROM `suppliers` AS 't1' WHERE (`t1`.`city` IN ('London', 'Paris'))")
        }
      end

      context 'when the operand is a NOT IN (values)' do
        let(:expr){ restrict(suppliers, !Predicate.in(:city, ["London", "Paris"])) }

        specify{
          subject.sql.should eq("SELECT * FROM `suppliers` AS 't1' WHERE (`t1`.`city` NOT IN ('London', 'Paris'))")
        }
      end

      context 'when the operand is a renaming' do
        let(:expr){ restrict(rename(suppliers, :name => :sname), :sname => "Jones") }

        specify{
          subject.sql.should eq("SELECT * FROM (SELECT `t1`.`name` AS 'sname', `t1`.`sid` AS 'sid', `t1`.`status` AS 'status', `t1`.`city` AS 'city' FROM `suppliers` AS 't1') AS 't2' WHERE (`t2`.`sname` = 'Jones')")
        }
      end

    end
  end
end