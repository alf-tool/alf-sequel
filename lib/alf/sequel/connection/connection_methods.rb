module Alf
  module Sequel
    class Connection
      module ConnectionMethods

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

        # Yields a Sequel::Database object
        def sequel_db
          @sequel_db ||= begin
            require 'sequel' unless defined?(::Sequel)
            ::Sequel.connect(conn_spec)
          end
          block_given? ? yield(@sequel_db) : @sequel_db
        end

      end # module ConnectionMethods
    end # module Connection
  end # module Sequel
end # module Alf
