module Alf
  module Sequel
    #
    # Specialization of Alf::Connection to distribute Sequel datasets
    #
    class Connection < ::Alf::Connection

      class << self

        # (see Alf::Connection.recognizes?)
        #
        # @return true if spec is one String that can be interpreted as a valid database
        # uri, or a Hash that looks like a conn spec in Sequel; false otherwise
        def recognizes?(conn_spec)
          case conn_spec
          when String
            require 'uri'
            uri = URI::parse(conn_spec) rescue nil
            (uri && uri.scheme) or looks_a_sqlite_file?(conn_spec)
          when Hash
            conn_spec = Tools.symbolize_keys(conn_spec)
            conn_spec[:adapter] && conn_spec[:database]
          else
            looks_a_sqlite_file?(conn_spec)
          end
        end

        # Returns true if `f` looks like a sqlite file
        def looks_a_sqlite_file?(f)
          return false unless Path.like?(f)
          path = Path(f)
          path.parent.directory? and ['db', 'sqlite', 'sqlite3'].include?(path.ext)
        end

        def sqlite_protocol
          defined?(JRUBY_VERSION) ? "jdbc:sqlite" : "sqlite"
        end

      end # class << self

      def initialize(*args)
        if self.class.looks_a_sqlite_file?(args.first)
          args[0] = "#{self.class.sqlite_protocol}://#{args.first}"
        end
        super(*args)
      end

      def compiler
        Compiler.new
      end

      require_relative 'connection/schema_methods'
      require_relative 'connection/connection_methods'
      require_relative 'connection/update_methods'
      include SchemaMethods
      include ConnectionMethods
      include UpdateMethods

      Alf::Connection.register(:sequel, self)
    end # class Connection
  end # module Sequel
end # module Alf
