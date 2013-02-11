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
          insert_uow(name, tuples).run
        end

        # Delete from the relvar called `name`
        def delete(name, predicate)
          delete_uow(name, predicate).run
        end

        # Updates the relvar called `name`
        def update(name, updating, predicate)
          update_uow(name, updating, predicate).run
        end

      public # should be private

        def with_dataset(name, predicate = nil)
          ds = name.is_a?(Symbol) ? sequel_db[name] : name
          if predicate && !predicate.tautology?
            ds = ds.filter(Compiler::Predicate.call(predicate))
          end
          yield(ds) if block_given?
        end

      private

        def insert_uow(name, tuples)
          UnitOfWork::Insert.new(self, name, tuples)
        end

        def delete_uow(name, predicate)
          UnitOfWork::Delete.new(self, name, predicate)
        end

        def update_uow(name, updating, predicate)
          UnitOfWork::Update.new(self, name, updating, predicate)
        end

      end # module UpdateMethods
    end # module Connection
  end # module Sequel
end # module Alf
