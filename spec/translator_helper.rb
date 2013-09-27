require 'alf-sql'
require 'alf-test'
require_relative 'spec_helper'

module TranslatorHelpers

  def db
    @db ||= ::Sequel.connect("postgres://pointguard@localhost/pointguard_test")
  end

  def conn
    Alf.connect(Path.dir, viewpoint: Alf::Test::Sap::Fake)
  end

  def builder
    @builder ||= Alf::Sql::Builder.new
  end

  def translator
    @translator ||= Alf::Sequel::Compiler::Translator.new(db)
  end

end

RSpec.configure do |c|
  c.include TranslatorHelpers
  c.after{
    @db.disconnect if @db
  }
end
