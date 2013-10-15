$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'alf-sequel'
require "rspec"
require 'path'
require 'logger'

module Helpers

  def sequel_database_path
    Path.dir/'sap.db'
  end

  def sequel_database_uri
    "#{Alf::Sequel::Adapter.sqlite_protocol}://#{sequel_database_path}"
  end

  def sequel_database_memory
    "#{Alf::Sequel::Adapter.sqlite_protocol}:memory"
  end

  def sap
    sequel_db = ::Sequel.connect(sequel_database_uri)
    Alf.connect(sequel_db, schema_cache: false)
  end

  def sap_memory
    sequel_db = ::Sequel.connect(sequel_database_memory)
    sequel_db.create_table(:suppliers) do
      String  :sid
      String  :name
      Integer :status
      String  :city
      primary_key [:sid]
      index :name, :unique => true
    end
    sequel_db.create_table(:parts) do
      String :pid
      String :name
      String :color
      Float  :weight
      String :city
      primary_key [:pid]
    end
    sequel_db.create_table(:supplies) do
      foreign_key :sid, :suppliers, :null=>false, :key=>[:sid], :deferrable=>true
      foreign_key :pid, :parts,     :null=>false, :key=>[:pid], :deferrable=>true
      Integer :qty
      primary_key [:sid, :pid]
    end
    [
      {:sid => 'S1', :name => 'Smith', :status => 20, :city => 'London'},
      {:sid => 'S2', :name => 'Jones', :status => 10, :city => 'Paris'},
      {:sid => 'S3', :name => 'Blake', :status => 30, :city => 'Paris'},
      {:sid => 'S4', :name => 'Clark', :status => 20, :city => 'London'},
      {:sid => 'S5', :name => 'Adams', :status => 30, :city => 'Athens'}
    ].each do |tuple|
      sequel_db[:suppliers].insert(tuple)
    end
    [
      {:pid => 'P1', :name => 'Nut',   :color => 'Red',   :weight => 12.0, :city => 'London'},
      {:pid => 'P2', :name => 'Bolt',  :color => 'Green', :weight => 17.0, :city => 'Paris'},
      {:pid => 'P3', :name => 'Screw', :color => 'Blue',  :weight => 17.0, :city => 'Oslo'},
      {:pid => 'P4', :name => 'Screw', :color => 'Red',   :weight => 14.0, :city => 'London'},
      {:pid => 'P5', :name => 'Cam',   :color => 'Blue',  :weight => 12.0, :city => 'Paris'},
      {:pid => 'P6', :name => 'Cog',   :color => 'Red',   :weight => 19.0, :city => 'London'}
    ].each do |tuple|
      sequel_db[:parts].insert(tuple)
    end
    Alf.connect(sequel_db, schema_cache: false)
  end

end

RSpec.configure do |c|
  c.include Helpers
  c.extend  Helpers
end
