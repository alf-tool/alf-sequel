require 'compiler_helper'
module Alf
  module Sequel
    class Compiler
      describe Predicate do

        let(:p)        { Alf::Predicate      }
        let(:compiler) { Predicate.new       }
        let(:compiled) { compiler.call(expr) }

        subject{ compiled.to_s(sap.connection.dataset(:suppliers)) }

        context 'tautology' do
          let(:expr){ p.tautology }

          it{ should eq("(1 = 1)") }
        end

        context 'contradiction' do
          let(:expr){ p.contradiction }

          it{ should eq("(1 = 0)") }
        end

        context 'var_ref' do
          let(:expr){ p.var_ref(:x) }

          it{ should eq("`x`") }
        end

        context 'literal' do
          let(:expr){ p.literal(12) }

          it{ should eq("12") }
        end

        context 'eq(var, literal)' do
          let(:expr){ p.eq(:x, 12) }

          it{ should eq("(`x` = 12)") }
        end

        context 'eq(var, var)' do
          let(:expr){ p.eq(:x, :y) }

          it{ should eq("(`x` = `y`)") }
        end

        context 'lt(var, literal)' do
          let(:expr){ p.lt(:x, 2) }

          it{ should eq("(`x` < 2)") }
        end

        context 'lte(var, literal)' do
          let(:expr){ p.lte(:x, 2) }

          it{ should eq("(`x` <= 2)") }
        end

        context 'gt(var, literal)' do
          let(:expr){ p.gt(:x, 2) }

          it{ should eq("(`x` > 2)") }
        end

        context 'gte(var, literal)' do
          let(:expr){ p.gte(:x, 2) }

          it{ should eq("(`x` >= 2)") }
        end

        context 'not(var)' do
          let(:expr){ p.not(:x) }

          it{ should eq("NOT `x`") }
        end

        context 'not(tautology)' do
          let(:expr){ p.not(true) }

          it{ should eq("(1 = 0)") }
        end

        context 'and' do
          let(:expr){ p.eq(:x, 2) & p.eq(:y, 3) }

          it{ should eq("((`x` = 2) AND (`y` = 3))") }
        end

        context 'or' do
          let(:expr){ p.eq(:x, 2) | p.eq(:y, 3) }

          it{ should eq("((`x` = 2) OR (`y` = 3))") }
        end

        context 'comp' do
          let(:expr){ p.comp(:lt, :x => 2, :y => 3) }

          it{ should eq("((`x` < 2) AND (`y` < 3))") }
        end

        context 'in' do
          let(:expr){ p.in(:x, [2, 3]) }

          it{ should eq("(`x` IN (2, 3))") }
        end

        context 'native' do
          let(:expr){ p.native(lambda{}) }

          specify{
            lambda{
              subject
            }.should throw_symbol(:pass)
          }
        end

      end
    end
  end
end