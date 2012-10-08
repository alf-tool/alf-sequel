require 'compiler_helper'
module Alf
  module Sequel
    describe Compiler, "leaf_operand" do

      subject{ compile(expr) }

      context 'on the proper context' do
        let(:expr){ suppliers }

        it{ should be_a(Cog) }
      end

      context 'on another context' do
        let(:expr){ Algebra.named_operand(:suppliers, self) }

        pending "support for multiple context is needed" do
          it{ should_not be_a(Cog) }
        end
      end

    end
  end
end