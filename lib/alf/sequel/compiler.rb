module Alf
  module Sequel
    class Compiler < Sql::Compiler

      def initialize(connection)
        super()
        @connection = connection
      end
      attr_reader :connection

    protected

      def fresh_cog(expr, sexpr)
        Cog.new(expr, self, sexpr, connection)
      end

      def rewrite(plan, expr, compiled, processor, args = [])
        rewrited = processor.new(*args.push(builder)).call(compiled.sexpr)
        Cog.new(expr, self, rewrited, compiled.connection)
      end

      def rebind(plan, expr, compiled)
        Cog.new(expr, self, compiled.sexpr, compiled.connection)
      end

    end # class Compiler
  end # module Sequel
end # module Alf
