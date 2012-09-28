$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'alf-sequel'
require "rspec"
require 'path'

module Helpers

  SUPPLIER_NAMES = ["Smith", "Clark", "Jones", "Blake", "Adams"]

  def supplier_names
    SUPPLIER_NAMES
  end

  def supplier_names_relation
    Relation(:name => supplier_names)
  end

  def sequel_database_path
    Path.dir/'alf.db'
  end

  def sequel_database_uri
    "#{Alf::Sequel::Connection.sqlite_protocol}://#{sequel_database_path}"
  end

  def sequel_database_memory
    "#{Alf::Sequel::Connection.sqlite_protocol}:memory"
  end

  def sequel_adapter(arg = sequel_database_path)
    Alf::Sequel::Connection.new(arg)
  end

  def sequel_names_adapter
    sequel_adapter(sequel_database_memory)
  end

  def create_names_schema(adapter, values = true)
    adapter.with_sequel_db do |c|
      c.drop_table(:names) if c.table_exists?(:names)
      c.create_table(:names) do
        primary_key :id
        String :name
      end
      supplier_names_relation.each do |tuple|
        c[:names].insert(tuple.to_hash)
      end if values
    end
    Alf::Relvar.new(adapter, adapter.iterator(:names))
  end

  def names_db
    ad = sequel_names_adapter
    create_names_schema(ad)
    ad
  end

  def sap
    @sap ||= Alf.connect Path.relative("fixtures/sap.db")
  end

end

RSpec.configure do |c|
  c.include Helpers
  c.extend  Helpers
  c.filter_run_excluding :ruby19 => (RUBY_VERSION < "1.9")
end