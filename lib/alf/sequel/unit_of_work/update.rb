module Alf
  module Sequel
    module UnitOfWork
      class Update
        include UnitOfWork::Atomic

        def initialize(connection, relvar_name, updating, predicate)
          super(connection)
          @relvar_name = relvar_name
          @updating    = updating
          @predicate   = predicate
        end

        def matching_relation
          raise IllegalStateError, "Unit of work not ran" unless ran?

          # Check that updating is understandable
          unless TupleLike===@updating
            raise UnsupportedError, "Non-tuple update feedback is unsupported."
          end
          updating = @updating.to_hash
          updating_keys = updating.keys

          # extract all keys, and pk in particular
          keys = connection.keys(@relvar_name)
          pk   = keys.first

          # Strategy 1), @updating contains a key
          if key = keys.to_a.find{|k| !(k & updating_keys).empty? }
            return Relation(@updating.project(key).to_hash)
          end

          raise UnsupportedError, "Unable to extract update matching relation"
        end

        def pk_matching_relation
          mr, pkey = matching_relation, connection.keys(@relvar_name).first
          if mr.to_attr_list == pkey.to_attr_list
            mr
          else
            filter = mr.tuple_extract.to_hash
            tuples = connection.cog(@relvar_name)
                               .filter(filter)
                               .select(pkey.to_a)
            Relation(tuples)
          end
        end

      private

        def _run
          connection.with_dataset(@relvar_name, @predicate) do |d|
            d.update Tuple(@updating).to_hash
          end
        end

      end # class Update
    end # module UnitOfWork
  end # module Sequel
end # module Alf
