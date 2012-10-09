require 'spec_helper'
module Alf
  module Sequel
    describe Adapter, "recognizes?" do

      it "recognizes ::Sequel::Database objects" do
        begin
          db = ::Sequel.connect(sequel_database_memory)
          Adapter.recognizes?(db).should be_true
        ensure
          db.disconnect if db
        end
      end

      it "recognizes sqlite files" do
        Adapter.recognizes?("#{sequel_database_path}").should be_true
      end

      it "recognizes in memory sqlite databases" do
        Adapter.recognizes?(sequel_database_memory).should be_true
      end

      it "recognizes a Path to a sqlite databases" do
        Adapter.recognizes?(sequel_database_path).should be_true
        Adapter.recognizes?("nosuchone.db").should be_true
      end

      it "recognizes database uris" do
        Adapter.recognizes?("postgres://localhost/database").should be_true
        Adapter.recognizes?(sequel_database_uri).should be_true
      end

      it "recognizes a Hash ala Rails" do
        config = {"adapter" => "sqlite", "database" => "#{sequel_database_path}"}
        Adapter.recognizes?(config).should be_true
        Adapter.recognizes?(Tools.symbolize_keys(config)).should be_true
      end

      it "should not be too permissive" do
        Adapter.recognizes?(nil).should be_false
      end

      it "should let Adapter autodetect sqlite files" do
        Alf::Adapter.autodetect(sequel_database_path).should be(Adapter)
        Alf::Adapter.autodetect("#{sequel_database_path}").should be(Adapter)
      end

    end
  end
end
