require 'spec_helper'
module Alf
  module Sequel
    unless Alf::Test.environment == :native
      describe Translator do

        def conn
          @conn ||= Alf::Test::Sap.connect
        end

        after(:each) do
          conn.adapter_connection.close!
        end

        def translator
          conn.adapter_connection.translator
        end

        subject{ translator.call(sql_cog.sexpr) }

        Alf::Test::Sap.each_query do |query|
          next unless query.sqlizable?

          context "on #{query}" do
            let(:alf_ast){ conn.parse(query.alf) }
            let(:sql_cog){ Alf::Sql::Compiler.new.call(alf_ast) }

            # before do
            #   puts "---"
            #   puts query['query']
            #   puts sql_cog.to_sql
            #   puts subject.sql
            # end

            it 'should lead to a valid dataset' do
              subject.should be_a(::Sequel::Dataset)
            end

            it 'should be valid SQL for the DBMS considered' do
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
