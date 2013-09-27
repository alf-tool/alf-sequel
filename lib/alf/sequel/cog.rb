module Alf
  module Sequel
    class Cog
      include Alf::Compiler::Cog
      include Enumerable

      def initialize(expr, compiler, sexpr, connection)
        super(expr, compiler)
        @sexpr = sexpr
        @connection = connection
      end
      attr_reader :sexpr, :connection

      def cog_orders
        [ sexpr.ordering ].compact
      end

      def dataset
        @dataset ||= Translator.new(connection).call(sexpr)
      end

      def to_sql(buffer = "")
        buffer << dataset.sql
        buffer
      end

      def each(&bl)
        return to_enum unless block_given?
        dataset.each(&bl)
      end

    end # class Cog
  end # module Sequel
end # module Alf
