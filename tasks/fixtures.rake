task :fixtures do
  require 'path'
  require "sequel"
  require "sqlite3"
  require 'alf-sequel'
  require_relative '../spec/fixtures/sap'

  path = Path.relative("../spec/fixtures/sap.db")
  path.unlink if path.exist?
  path.parent.mkdir_p unless path.parent.exist?

  SAP.create! Alf::Sequel::Adapter.sequel_db(path)
end
