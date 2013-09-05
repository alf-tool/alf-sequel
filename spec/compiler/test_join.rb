require 'compiler_helper'
module Alf
  module Sequel
    describe Compiler, "join" do

      subject{ compile(expr) }

      context 'when the operand is fully compilable' do
        let(:expr){ join(suppliers, supplies) }

        specify do
          subject.sql.should eq("SELECT * FROM (SELECT * FROM (SELECT * FROM `suppliers` AS 't1') AS 't1' INNER JOIN (SELECT * FROM `supplies` AS 't2') AS 't3' USING (`sid`)) AS 't3'")
        end
      end

      context 'when the left operand is a projection' do
        let(:expr){ join(project(suppliers, [:sid]), supplies) }

        specify do
          subject.sql.should eq("SELECT * FROM (SELECT * FROM (SELECT `t1`.`sid` FROM `suppliers` AS 't1') AS 't1' INNER JOIN (SELECT * FROM `supplies` AS 't2') AS 't3' USING (`sid`)) AS 't3'")
        end
      end

    end
  end
end