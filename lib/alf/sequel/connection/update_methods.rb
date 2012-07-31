module Alf
  module Sequel
    class Connection
      module UpdateMethods

        # Yields the block in a transaction
        def in_transaction(&bl)
          sequel_db.transaction(&bl)
        end

        # Inserts `tuples` in the relvar called `name`
        def insert(name, tuples)
          with_dataset(name) do |d|
            options = {:return => :primary_key}
            Alf::Relation :id => d.multi_insert(tuples, options)
          end
        end

        # Delete from the relvar called `name`
        def delete(name, predicate)
          with_dataset(name, predicate) do |d|
            d.delete
          end
        end

        # Updates the relvar called `name`
        def update(name, computation, predicate)
          with_dataset(name, predicate) do |d|
            d.update Tuple(computation)
          end
        end

      private

        def with_dataset(name, predicate = nil)
          ds = sequel_db[name]
          if predicate && !predicate.tautology?
            ds = ds.filter(Compiler::Predicate.call(predicate))
          end
          yield(ds)
        end

      end # module UpdateMethods
    end # module Connection
  end # module Sequel
end # module Alf
