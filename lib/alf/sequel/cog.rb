module Alf
  module Sequel
    class Cog
      include Alf::Compiler::Cog
      include Enumerable

      def initialize(expr, compiler, sexpr)
        super(expr, compiler)
        @sexpr = sexpr
      end
      attr_reader :sexpr

      def should_be_reused?
        sexpr.should_be_reused?
      end

      def cog_orders
        [ sexpr.ordering ].compact
      end

      def dataset
        @dataset ||= Translator.new(compiler.connection).call(sexpr)
      end

      def to_sql(buffer = "")
        buffer << dataset.sql
        buffer
      end

      def to_s
        "Alf::Sequel::Cog(#{to_sql})"
      end

      def each(&bl)
        return to_enum unless block_given?
        dataset.each(&bl)
      end

    end # class Cog
  end # module Sequel
end # module Alf
