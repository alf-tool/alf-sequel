require 'compiler_helper'
module Alf
  module Sequel
    describe Compiler, "sort" do

      subject{ compile(expr) }

      context 'when the operand is fully compilable' do
        let(:expr){ sort(suppliers, [ [:name, :asc], [:status, :desc] ]) }

        specify{
          subject.sql.should eq("SELECT * FROM `suppliers` ORDER BY `name` ASC, `status` DESC")
        }
      end

    end
  end
end