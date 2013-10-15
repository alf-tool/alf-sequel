require 'spec_helper'
module Alf
  module Sequel
    describe Connection, "ping" do

      it "returns true on a file" do
        Connection.new("#{sequel_database_path}").ping.should be_true
      end

      it "returns true on an uri" do
        Connection.new(sequel_database_uri).ping.should be_true
      end

      it "returns true on a Path" do
        Connection.new(sequel_database_path).ping.should be_true
      end

      it "raises on non existing" do
        lambda {
          Connection.new("postgres://non-existing.sqlite3").ping
        }.should raise_error
      end

    end
  end
end
