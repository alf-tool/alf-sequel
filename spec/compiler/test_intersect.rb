require 'compiler_helper'
module Alf
  module Sequel
    describe Compiler, "intersect" do

      subject{ compile(expr) }

      context 'when the operand is fully compilable' do
        let(:expr){ intersect(suppliers, supplies) }

        specify do
          subject.sql.should eq("SELECT * FROM (SELECT * FROM `suppliers` INTERSECT SELECT * FROM `supplies`) AS 't1'")
        end
      end

    end
  end
end