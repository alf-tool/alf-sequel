require 'compiler_helper'
module Alf
  module Sequel
    describe Compiler, "var_ref" do

      subject{ compile(expr) }

      context 'on the proper context' do
        let(:expr){ suppliers }

        it{ should be_a(Operand::Compiled) }
      end

      context 'on another context' do
        let(:expr){ Alf::Database.examples.iterator(:suppliers) }

        pending "support for multiple context is needed" do
          it{ should_not be_a(Operand::Compiled) }
        end
      end

    end
  end
end