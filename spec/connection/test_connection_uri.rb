require 'spec_helper'
module Alf
  module Sequel
    describe Connection, 'connection_uri' do

      subject{ conn.connection_uri }

      context 'when build with an uri' do
        let(:conn){ Connection.new("somewhere/to/db.sqlite3") }

        it{ should eq("somewhere/to/db.sqlite3") }
      end

      context 'when build with no host on sqlite' do
        let(:conn){ Connection.new({:adapter => "sqlite", :database => "sap.db"}) }

        it{ should eq("sqlite://sap.db") }
      end

      context 'when build with no host on postgres' do
        let(:conn){ Connection.new({:adapter => "postgres", :database => "sap"}) }

        it{ should eq("postgres://localhost/sap") }
      end

      context 'when build with a host but no port' do
        let(:conn){ Connection.new({:adapter => "postgres", :host => "athena", :database => "sap"}) }

        it{ should eq("postgres://athena/sap") }
      end

      context 'when build with a host and a no port' do
        let(:conn){ Connection.new({:adapter => "postgres", :host => "athena", :port => 1234, :database => "sap"}) }

        it{ should eq("postgres://athena:1234/sap") }
      end
    end
  end
end