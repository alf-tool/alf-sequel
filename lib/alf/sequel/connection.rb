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

      def iterator(name)
        raise NoSuchRelvarError, "No such table `#{name}`" unless sequel_db.table_exists?(name)
        sequel_db[name]
      end

      def base_relvar(name)
        raise NoSuchRelvarError, "No such table `#{name}`" unless sequel_db.table_exists?(name)
        Relvar.new(self, name)
      end

      def heading(name)
        h = {}
        sequel_db.schema(name).each do |pair|
          column_name, info = pair
          h[column_name] = dbtype_to_ruby_type(info)
        end
        Heading.new(h)
      end

      def keys(name)
        # take the indexes
        indexes = sequel_db.indexes(name).
                            values.
                            select{|i| i[:unique] == true }.
                            map{|i| AttrList.coerce(i[:columns]) }.
                            sort{|a1, a2| a1.size <=> a2.size}

        # take single keys as well
        key = sequel_db.schema(name).
                        select{|(colname, colinfo)| colinfo[:primary_key] }.
                        map(&:first)
        indexes.unshift(AttrList.coerce(key)) unless key.empty?

        Keys.new(indexes)
      end

      def ping
        sequel_db.test_connection
      end

      def close
        @sequel_db.disconnect if @sequel_db
      end

      def with_connection
        yield(sequel_db)
      end
      alias :with_sequel_db :with_connection

    private

      def dbtype_to_ruby_type(info)
        begin
          Kernel.eval(info[:type].to_s.capitalize)
        rescue NameError
          case type
          when :datetime then Time
          when :boolean  then Alf::Boolean
          else Object
          end
        end
      end

      # Yields a Sequel::Database object
      def sequel_db
        @sequel_db ||= begin
          require 'sequel' unless defined?(::Sequel)
          ::Sequel.connect(conn_spec)
        end
        block_given? ? yield(@sequel_db) : @sequel_db
      end

      Alf::Connection.register(:sequel, self)
    end # class Connection
  end # module Sequel
end # module Alf
