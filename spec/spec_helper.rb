$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'alf-test'
require 'alf-sequel'
require "rspec"
require 'path'
require 'logger'

module Helpers

  def sequel_database_path
    Path.dir/'alf.db'
  end

  def sequel_database_uri
    Alf::Test::Sap.sequel_uri(:sqlite)
  end

  def sequel_database_memory
    Alf::Test::Sap.sequel_uri(:memory)
  end

  def sap
    Alf::Test::Sap.connect(:memory, schema_cache: false)
  end

  def sap_memory
    Alf::Test::Sap.connect(:memory, schema_cache: false)
  end

end

RSpec.configure do |c|
  c.include Helpers
  c.extend  Helpers
end
