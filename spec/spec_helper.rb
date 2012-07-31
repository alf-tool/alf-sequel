$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'alf-sequel'
require "rspec"
require 'epath'

module Helpers

  SUPPLIER_NAMES = ["Smith", "Clark", "Jones", "Blake", "Adams"]

  def supplier_names
    SUPPLIER_NAMES
  end

  def supplier_names_relation
    Relation(:name => supplier_names)
  end

  def examples_database(&bl)
    Alf::Database.examples
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
  alias :sequel_connection :sequel_adapter

  def sequel_names_adapter
    sequel_adapter(sequel_database_memory)
  end

  def create_names_schema(adapter, values = true)
    adapter.with_connection do |c|
      c.drop_table(:names) if c.table_exists?(:names)
      c.create_table(:names) do
        primary_key :id
        String :name
      end
      supplier_names_relation.each do |tuple|
        c[:names].insert(tuple)
      end if values
    end
    Alf::Relvar.new(adapter, Alf::Operator::VarRef.new(adapter, :names))
  end

  def names_db
    ad = sequel_names_adapter
    create_names_schema(ad)
    Alf.connect(ad)
  end

  def sap
    @sap ||= Alf.connect Path.relative("fixtures/sap.db")
  end

  def sap_connection
    sap.connection
  end

end

RSpec.configure do |c|
  c.include Helpers
  c.extend  Helpers
  c.filter_run_excluding :ruby19 => (RUBY_VERSION < "1.9")
end