require 'compiler_helper'
module Alf
  module Sequel
    describe Compiler, "join" do

      subject{ compile(expr) }

      context 'when the operand is fully compilable' do
        let(:expr){ join(suppliers, supplies) }

        specify do
          subject.sql.should eq("SELECT * FROM `suppliers` NATURAL JOIN (SELECT * FROM `supplies`) AS 't1'")
        end
      end

    end
  end
end