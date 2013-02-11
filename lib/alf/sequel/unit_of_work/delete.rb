module Alf
  module Sequel
    module UnitOfWork
      class Delete
        include UnitOfWork::Atomic

        def initialize(connection, relvar_name, predicate)
          super(connection)
          @relvar_name   = relvar_name
          @predicate     = predicate
        end

      private

        def _run
          connection.with_dataset(@relvar_name, @predicate) do |d|
            d.delete
          end
        end

      end # class Delete
    end # module UnitOfWork
  end # module Sequel
end # module Alf
