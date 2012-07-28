require 'compiler_helper'
module Alf
  module Sequel
    describe Compiler, "var_ref" do

      subject{ compile(expr) }

      context 'on the proper context' do
        let(:expr){ var_ref(:suppliers) }

        it{ should be_a(Sequel::Iterator) }
      end

      context 'on another context' do
        let(:expr){ var_ref(:suppliers, Alf::Database.examples) }

        pending "support for multiple context is needed" do
          it{ should_not be_a(Sequel::Iterator) }
        end
      end

    end
  end
end