require 'translator_helper'
module Alf
  module Sequel
    describe Translator do

      subject{ Translator.new(db).call(sql_cog.sexpr) }

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

          it{ should be_a(::Sequel::Dataset) }
        end
      end

    end
  end
end
  