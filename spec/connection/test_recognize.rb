require 'spec_helper'
module Alf
  module Sequel
    describe Connection, "recognizes?" do

      it "recognizes sqlite files" do
        Connection.recognizes?("#{sequel_database_path}").should be_true
      end

      it "recognizes in memory sqlite databases" do
        Connection.recognizes?(sequel_database_memory).should be_true
      end

      it "recognizes a Path to a sqlite databases" do
        Connection.recognizes?(sequel_database_path).should be_true
        Connection.recognizes?("nosuchone.db").should be_true
      end

      it "recognizes database uris" do
        Connection.recognizes?("postgres://localhost/database").should be_true
        Connection.recognizes?(sequel_database_uri).should be_true
      end

      it "recognizes a Hash ala Rails" do
        config = {"adapter" => "sqlite", "database" => "#{sequel_database_path}"}
        Connection.recognizes?(config).should be_true
        Connection.recognizes?(Tools.symbolize_keys(config)).should be_true
      end

      it "should not be too permissive" do
        Connection.recognizes?(nil).should be_false
      end

      it "should let Connection autodetect sqlite files" do
        Alf::Connection.autodetect(sequel_database_path).should eq(Connection)
        Alf::Connection.autodetect("#{sequel_database_path}").should eq(Connection)
      end

    end
  end
end
