module Alf
  module Sequel
    module UnitOfWork
      class Insert
        include UnitOfWork::Atomic

        def initialize(connection, relvar_name, inserted)
          super(connection)
          @relvar_name   = relvar_name
          @inserted      = inserted
          @insert_result = nil
        end

        def matching_relation
          raise IllegalStateError, "Unit of work not ran" unless ran?
          pk = connection.keys(@relvar_name).first
          if pk && pk.size == 1
            Relation(pk.to_a.first => @insert_result)
          else
            raise UnsupportedError, "Composite keys insertion feedback is unsupported."
          end
        end

      private

        def _run
          connection.with_dataset(@relvar_name) do |d|
            @insert_result = d.insert_multiple(@inserted){|t| t.to_hash}
          end
        end

      end # class Insert
    end # module UnitOfWork
  end # module Sequel
end # module Alf
