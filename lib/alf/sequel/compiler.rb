module Alf
  module Sequel
    class Compiler < Sql::Compiler

      def initialize(connection)
        super()
        @connection = connection
      end
      attr_reader :connection

    protected

      def cog_class
        Cog
      end

    end # class Compiler
  end # module Sequel
end # module Alf
