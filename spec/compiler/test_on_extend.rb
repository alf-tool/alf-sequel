require 'compiler_helper'
module Alf
  module Sequel
    describe Compiler, "extend" do

      subject{ compile(expr) }

      context 'with a native predicate' do
        let(:expr){ extend(:suppliers, :big => lambda{}) }
      
        it{ should be_a(Engine::SetAttr) }
      end
      
    end
  end
end