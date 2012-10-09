module Alf
  module Sequel
    class Adapter < Alf::Adapter

      class << self

        def recognizes?(conn_spec)
          case conn_spec
          when ::Sequel::Database
            true
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

        def sequel_db(conn_spec)
          require 'sequel' unless defined?(::Sequel)
          case conn_spec
          when ::Sequel::Database
            conn_spec
          when String, Path
            conn_spec = "#{sqlite_protocol}://#{conn_spec}" if looks_a_sqlite_file?(conn_spec)
            ::Sequel.connect(conn_spec)
          else
            raise ArgumentError, "Unrecognized connection specification `#{conn_spec.inspect}`"
          end
        end

      end # class << self

      # Returns a low-level connection on this adapter
      def connection
        Connection.new(conn_spec)
      end

      ::Alf::Adapter.register(:sequel, self)
    end # class Adapter
  end # module Sequel
end # module Alf
