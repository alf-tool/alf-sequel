require 'spec_helper'
module Alf
  module Sequel
    unless Alf::Test.environment == :native
      describe Compiler do

        def conn
          @conn ||= Alf::Test::Sap.connect
        end

        after(:each) do
          conn.adapter_connection.close!
        end

        Alf::Test::Sap.each_query do |query|
          #next unless query.alf =~ /DEE/

          context "on #{query}" do
            # before do
            #   puts "---"
            #   puts query['query']
            #   puts sql_cog.to_sql
            #   puts subject.sql
            # end

            subject{ conn.parse(query.alf).to_cog }

            if query.sqlizable?

              it 'should lead to a Sequel::Cog' do
                subject.should be_a(Cog)
              end

              it 'should be valid SQL for the DBMS considered' do
              end
            end

            it 'should run without problem' do
              lambda{
                subject.to_a
              }.should_not(raise_error)
            end
          end
        end

      end
    end
  end
end
