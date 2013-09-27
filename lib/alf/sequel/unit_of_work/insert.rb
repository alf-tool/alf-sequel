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
          @matching_relation ||= begin
            raise IllegalStateError, "Unit of work not ran" unless ran?
            unless @insert_result
              raise UnsupportedError, "Composite keys insertion feedback is unsupported."
            end
            Relation(@insert_result)
          end
        end

      private

        def candidate_keys
          @candidate_keys ||= connection.keys(@relvar_name)
        end

        def primary_key
          candidate_keys.first
        end

        def best_candidate_key
          best = candidate_keys.to_a.find{|k| k.size == 1}
          best || candidate_keys.first
        end

        def _run
          connection.with_dataset(@relvar_name) do |d|
            bk = best_candidate_key
            supported = d.supports_returning?(:insert)

            if supported and bk and bk.size == 1
              pk_field_name = bk.to_a.first
              d = d.returning(pk_field_name) if supported
              @insert_result = @inserted.map{|t|
                d.insert(t.to_hash).first
              }
            elsif bk
              pk_field_name = bk.to_a.first
              @insert_result = @inserted.map{|t|
                result = d.insert(t.to_hash)
                bk.project_tuple(t) || { pk_field_name => result }
              }
            else
              @inserted.each{|t| d.insert(t.to_hash) }
              @insert_result = nil
            end
          end
        end

      end # class Insert
    end # module UnitOfWork
  end # module Sequel
end # module Alf
