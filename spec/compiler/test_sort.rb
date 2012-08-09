require 'compiler_helper'
module Alf
  module Sequel
    describe Compiler, "sort" do

      subject{ compile(expr) }

      context 'when the operand is fully compilable' do
        let(:expr){ sort(suppliers, [ [:name, :asc], [:status, :desc] ]) }

        specify{
          subject.sql.should eq("SELECT * FROM `suppliers` AS 't1' ORDER BY `t1`.`name` ASC, `t1`.`status` DESC")
        }
      end

    end
  end
end