require 'compiler_helper'
module Alf
  module Sequel
    describe Compiler, "union" do

      subject{ compile(expr) }

      context 'when the operand is fully compilable' do
        let(:expr){ union(suppliers, supplies) }

        specify do
          subject.sql.should eq("SELECT * FROM (SELECT * FROM `suppliers` AS 't1' UNION SELECT * FROM `supplies` AS 't2') AS 't3'")
        end
      end

    end
  end
end