require 'compiler_helper'
module Alf
  module Sequel
    describe Compiler, "page" do

      subject{ compile(expr) }

      let(:expr){
        page(operand, ordering, page_index, page_size: 8)
      }

      context 'when fully compilable' do
        let(:operand){ suppliers }

        [
          [ [[:name, :asc]],  2, "SELECT * FROM `suppliers` AS 't1' ORDER BY `t1`.`name` ASC LIMIT 8 OFFSET 8" ],
          [ [[:name, :asc]], -2, "SELECT * FROM `suppliers` AS 't1' ORDER BY `t1`.`name` DESC LIMIT 8 OFFSET 8" ],
          [ [[:city, :asc]],  2, "SELECT * FROM `suppliers` AS 't1' ORDER BY `t1`.`city` ASC, `t1`.`sid` ASC LIMIT 8 OFFSET 8" ],
          [ [[:city, :asc]], -2, "SELECT * FROM `suppliers` AS 't1' ORDER BY `t1`.`city` DESC, `t1`.`sid` DESC LIMIT 8 OFFSET 8" ],
        ].each do |(ordering,page_index,expected)|

          context "page(#{ordering}, #{page_index})" do
            let(:ordering)  { ordering   }
            let(:page_index){ page_index }

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
          [ [[:name, :asc]], 2, [[:name, :asc]] ],
          [ [[:city, :asc]], 2, [[:city, :asc], [:sid, :asc]] ]
        ].each do |ordering, page_index, expected|

          context "page(#{ordering}, #{page_index})" do
            let(:ordering)  { ordering   }
            let(:page_index){ page_index }

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
          [ [[:name, :asc]], 2, [[:name, :asc]] ],
          [ [[:city, :asc]], 2, [[:city, :asc]] ]
        ].each do |ordering, page_index, expected|

          context "page(#{ordering}, #{page_index})" do
            let(:ordering)  { ordering   }
            let(:page_index){ page_index }

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