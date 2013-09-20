require 'compiler_helper'
module Alf
  module Sequel
    describe Compiler, "not_matching" do

      subject{ compile(expr) }

      context 'when no common attributes' do
        let(:expr){ not_matching(suppliers, project(supplies, [:part_id])) }

        specify do
          subject.sql.should eq("SELECT * FROM `suppliers` AS 't1' WHERE NOT (EXISTS (SELECT DISTINCT `t2`.`part_id` FROM `supplies` AS 't2'))")
        end
      end

      context 'when only one common attributes' do
        let(:expr){ not_matching(suppliers, supplies) }

        specify do
          subject.sql.should eq("SELECT * FROM `suppliers` AS 't1' WHERE (`t1`.`sid` NOT IN (SELECT `t2`.`sid` FROM `supplies` AS 't2'))")
        end
      end

      context 'when many common attributes' do
        let(:expr){ not_matching(suppliers, parts) }

        specify do
          subject.sql.should eq("SELECT * FROM `suppliers` AS 't1' WHERE NOT (EXISTS (SELECT * FROM `parts` AS 't2' WHERE ((`t1`.`name` = `t2`.`name`) AND (`t1`.`city` = `t2`.`city`))))")
        end
      end

    end
  end
end