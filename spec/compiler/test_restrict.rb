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
          subject.sql.should eq("SELECT * FROM `suppliers` WHERE (`name` = 'Jones')")
        }
      end

    end
  end
end