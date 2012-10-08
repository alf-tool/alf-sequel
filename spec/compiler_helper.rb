require_relative 'spec_helper'

module CompilerHelpers
  include Alf::Lang::Functional

  def suppliers
    Alf::Algebra.named_operand(:suppliers, sap)
  end

  def supplies
    Alf::Algebra.named_operand(:supplies, sap)
  end

  def parts
    Alf::Algebra.named_operand(:parts, sap)
  end

  def _context
    sap
  end

  def an_operand
    Alf::Algebra::Operand::Fake.new(sap)
  end

  def compile(expr)
    Alf::Sequel::Compiler.new.call(expr)
  end

end

RSpec.configure do |c|
  c.include CompilerHelpers
end