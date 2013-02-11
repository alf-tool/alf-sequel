module Alf
  module Sequel
    module UnitOfWork
      class Update
        include UnitOfWork::Atomic

        def initialize(connection, relvar_name, updating, predicate)
          super(connection)
          @relvar_name   = relvar_name
          @updating      = updating
          @predicate     = predicate
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
