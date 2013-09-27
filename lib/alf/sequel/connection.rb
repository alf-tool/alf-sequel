module Alf
  module Sequel
    #
    # Specialization of Alf::Connection to distribute Sequel datasets
    #
    class Connection < Alf::Adapter::Connection

      def compiler
        @compiler ||= Compiler.new(self)
      end

      def translator
        @translator ||= Translator.new(self)
      end

      require_relative 'connection/schema_methods'
      require_relative 'connection/connection_methods'
      require_relative 'connection/update_methods'
      include SchemaMethods
      include ConnectionMethods
      include UpdateMethods

      alias_method :to_s, :connection_uri

    end # class Connection
  end # module Sequel
end # module Alf
