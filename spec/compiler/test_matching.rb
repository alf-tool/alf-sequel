require 'compiler_helper'
module Alf
  module Sequel
    describe Compiler, "matching" do

      subject{ compile(expr) }

      context 'when only one common attributes' do
        let(:expr){ matching(suppliers, supplies) }

        specify do
          subject.sql.should eq("SELECT * FROM `suppliers` AS 't1' WHERE (`t1`.`sid` IN (SELECT `t2`.`sid` FROM `supplies` AS 't2'))")
        end
      end

      context 'when many common attributes' do
        let(:expr){ matching(suppliers, parts) }

        specify do
          subject.sql.should eq("SELECT * FROM `suppliers` AS 't1' WHERE (EXISTS (SELECT * FROM `parts` AS 't2' WHERE ((`t1`.`name` = `t2`.`name`) AND (`t1`.`city` = `t2`.`city`))))")
        end
      end

    end
  end
end