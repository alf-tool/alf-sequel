module Alf
  module Sequel
    class Connection
      module UpdateMethods

        # Yields the block in a transaction
        def in_transaction(&bl)
          sequel_db.transaction(&bl)
        end

        def lock(name, mode, &bl)
          with_dataset(name){|ds|
            if ds.respond_to?(:lock)
              ds.lock(mode.to_s.upcase, &bl)
            else
              yield
            end
          }
        end

        # Inserts `tuples` in the relvar called `name`
        def insert(name, tuples)
          tuples = tuples.map{|t| t.to_hash}
          with_dataset(name) do |d|
            options = {:return => :primary_key}
            inserted_ids = d.multi_insert(tuples, options)
            if (key = keys(name).first) && (key.size==1)
              Alf::Relation key.to_a.first => inserted_ids
            else
              Alf::Relation :id => inserted_ids
            end
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
            d.update Tuple(computation).to_hash
          end
        end

      private

        def with_dataset(name, predicate = nil)
          ds = name.is_a?(Symbol) ? sequel_db[name] : name
          if predicate && !predicate.tautology?
            ds = ds.filter(Compiler::Predicate.call(predicate))
          end
          yield(ds)
        end

      end # module UpdateMethods
    end # module Connection
  end # module Sequel
end # module Alf
