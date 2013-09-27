$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'alf-sequel'
require "rspec"
require 'path'
require_relative 'fixtures/sap.rb'

module Helpers

  def sequel_database_path
    Path.dir/'alf.db'
  end

  def sequel_database_uri
    "#{Alf::Sequel::Adapter.sqlite_protocol}://#{sequel_database_path}"
  end

  def sequel_database_memory
    "#{Alf::Sequel::Adapter.sqlite_protocol}::memory:"
  end

  def sap
    @sap ||= Alf.connect Path.relative("fixtures/sap.db")
  end

  def sap_memory
    Alf.connect(SAP.create!(sequel_database_memory), schema_cache: false)
  end

end

RSpec.configure do |c|
  c.include Helpers
  c.extend  Helpers
end
