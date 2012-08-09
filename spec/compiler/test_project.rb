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

      context 'when the operand is fully compilable (allbut, distinct)' do
        let(:expr){ project(suppliers, [:sid, :name, :status], :allbut => true) }

        specify{
          subject.sql.should eq("SELECT DISTINCT `t1`.`city` FROM `suppliers` AS 't1'")
        }
      end

      context 'when the operand is not compilable' do
        let(:expr){ project(an_operand, [:sid, :name]) }

        it{ should be_a(Engine::Cog) }
      end

    end
  end
end