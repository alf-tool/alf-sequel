task :fixtures do
  require 'path'
  require "sequel"
  require "sqlite3"
  require 'alf'
  require 'alf-sequel'
  require 'letters'

  path = Path.relative("../spec/fixtures/sap.db")
  path.unlink if path.exist?
  path.parent.mkdir_p unless path.parent.exist?

  sequel_db = Alf::Sequel::Adapter.sequel_db(path)
  sequel_db.tap do |db|
    db.create_table(:suppliers) do
      primary_key :sid
      String :name
      Integer :status
      String :city
      index :name, :unique => true
    end
    db.create_table(:parts) do
      primary_key :pid
      String :name
      String :color
      Float :weight
      String :city
    end
    db.create_table(:supplies) do
      Integer :sid
      Integer :pid
      Integer :qty
      primary_key [:sid, :pid]
    end
  end

  Alf.connect(sequel_db) do |alf_db|
    ex = Alf.examples
    alf_db.relvar(:suppliers).affect ex.query{
      (extend suppliers, :sid => lambda{ (sid.match /\d+/)[0].to_i })
    }
    alf_db.relvar(:parts).affect ex.query{
      (extend parts, :pid => lambda{ (pid.match /\d+/)[0].to_i })
    }
    alf_db.relvar(:supplies).affect ex.query{
      (extend supplies, :sid => lambda{ (sid.match /\d+/)[0].to_i },
                        :pid => lambda{ (pid.match /\d+/)[0].to_i })
    }
  end
end