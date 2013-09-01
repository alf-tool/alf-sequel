require 'compiler_helper'
module Alf
  module Sequel
    describe Compiler, "frame" do

      subject{ compile(expr) }

      let(:expr){
        frame(operand, ordering, offset, limit)
      }

      context 'when fully compilable' do
        let(:operand){ suppliers }

        [
          [ [[:name, :asc]],  0, 8, "SELECT * FROM `suppliers` AS 't1' ORDER BY `t1`.`name` ASC LIMIT 8 OFFSET 0" ],
          [ [[:name, :asc]],  2, 8, "SELECT * FROM `suppliers` AS 't1' ORDER BY `t1`.`name` ASC LIMIT 8 OFFSET 2" ],
          [ [[:city, :asc]],  0, 8, "SELECT * FROM `suppliers` AS 't1' ORDER BY `t1`.`city` ASC, `t1`.`sid` ASC LIMIT 8 OFFSET 0" ],
          [ [[:city, :desc]],  2, 8, "SELECT * FROM `suppliers` AS 't1' ORDER BY `t1`.`city` DESC, `t1`.`sid` ASC LIMIT 8 OFFSET 2" ],
        ].each do |(ordering,offset,limit,expected)|

          context "frame(#{ordering}, #{offset}, #{limit})" do
            let(:ordering){ ordering }
            let(:offset)  { offset   }
            let(:limit)   { limit    }

            it 'should compile as expected' do
              subject.sql.should eq(expected)
            end
          end

        end
      end # fully compilable

      context 'when immediately uncompilable yet known keys' do
        let(:operand){
          Algebra::Operand::Fake.new.with_keys([:sid], [:name])
        }

        [
          [ [[:name, :asc]], 2, 8, [[:name, :asc]] ],
          [ [[:city, :asc]], 2, 8, [[:city, :asc], [:sid, :asc]] ]
        ].each do |ordering, offset, limit, expected|

          context "frame(#{ordering}, #{offset}, #{limit})" do
            let(:ordering){ ordering }
            let(:offset)  { offset   }
            let(:limit)   { limit    }

            it{ should be_a(Engine::Take) }

            it 'should have sort with good ordering' do
              subject.operand.should be_a(Engine::Sort)
              subject.operand.ordering.should eq(Ordering.new(expected))
            end
          end

        end
      end

      context 'when immediately uncompilable yet unknown keys' do
        let(:operand){
          Algebra::Operand::Fake.new
        }

        [
          [ [[:name, :asc]], 2, 8, [[:name, :asc]] ],
          [ [[:city, :asc]], 2, 8, [[:city, :asc]] ]
        ].each do |ordering, offset, limit, expected|

          context "frame(#{ordering}, #{offset}, #{limit})" do
            let(:ordering){ ordering }
            let(:offset)  { offset   }
            let(:limit)   { limit    }

            it{ should be_a(Engine::Take) }

            it 'should have sort with good ordering' do
              subject.operand.should be_a(Engine::Sort)
              subject.operand.ordering.should eq(Ordering.new(expected))
            end
          end

        end
      end

    end
  end
end