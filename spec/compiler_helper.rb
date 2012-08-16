require_relative 'spec_helper'

module CompilerHelpers
  include Alf::Lang::Functional

  def suppliers
    sap.iterator(:suppliers)
  end

  def supplies
    sap.iterator(:supplies)
  end

  def parts
    sap.iterator(:parts)
  end

  def _context
    sap
  end

  def an_operand
    Alf::Tools::FakeOperand.new(sap)
  end

  def compile(expr)
    Alf::Sequel::Compiler.new.call(expr)
  end

end

RSpec.configure do |c|
  c.include CompilerHelpers
end