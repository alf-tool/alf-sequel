module Alf
  module Sequel
    #
    # Specialization of Alf::Connection to distribute Sequel datasets
    #
    class Connection < Alf::Adapter::Connection

      def compiler
        Compiler.new
      end

      require_relative 'connection/schema_methods'
      require_relative 'connection/connection_methods'
      require_relative 'connection/update_methods'
      include SchemaMethods
      include ConnectionMethods
      include UpdateMethods

      alias :to_s :connection_uri

    end # class Connection
  end # module Sequel
end # module Alf
