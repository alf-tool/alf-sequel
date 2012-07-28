require 'compiler_helper'
module Alf
  module Sequel
    describe Compiler, "compact" do

      subject{ compile(expr) }

      context 'when the operand is fully compilable' do
        let(:expr){ compact(:suppliers) }

        specify{
          subject.sql.should eq("SELECT DISTINCT * FROM `suppliers`")
        }
      end

    end
  end
end