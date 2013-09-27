require 'translator_helper'
module Alf
  module Sequel
    describe Translator do

      subject{ Translator.new(db).call(sql_cog.sexpr) }

      Alf::Test.each_query do |query|
        next unless query['sql']

        context "on `#{query['query']}`" do
          let(:alf_ast){ conn.parse(query['query']) }
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
  