module Alf
  module Sequel
    class Operand
      class Compiled < Operand
        include Alf::Iterator

        def initialize(connection, dataset, as)
          @connection = connection
          @dataset = dataset
          @as = as
        end
        attr_reader :connection, :dataset, :as

        def main_scope
          connection.scope
        end

        def each
          dataset.each(&Proc.new)
        end

        ### Delegation to Dataset, that is, facade over ::Sequel itself

        def select(attributes)
          attributes = qualify(attributes)
          case attributes
          when Hash
            branch dataset.select(attributes)
          else
            branch dataset.select(*attributes)
          end
        end

        def distinct(*args, &bl)
          branch dataset.distinct(*args, &bl)
        end

        def order(*args, &bl)
          branch dataset.order(*args, &bl)
        end

        def filter(*args, &bl)
          branch dataset.filter(*args, &bl)
        end

        def intersect(other, opts={})
          branch dataset.intersect(other.dataset, opts), opts[:alias]
        end

        def join(other, cols, opts={})
          join = dataset.inner_join(other.dataset, cols, :table_alias => opts[:alias])
          branch join.from_self(opts), opts[:alias]
        end

        def union(other, opts={})
          branch dataset.union(other.dataset, opts), opts[:alias]
        end

        def sql
          dataset.sql
        end

        def qualify(attributes)
          return attributes unless as
          case attributes
          when Symbol then ::Sequel.qualify(as, attributes)
          when Hash   then Hash[attributes.each_pair.map{|k,v| [::Sequel.qualify(as, k), v] }]
          else
            attributes.map{|attr| ::Sequel.qualify(as, attr)}
          end
        end

      private

        def branch(ds, as=self.as)
          Compiled.new connection, ds, as
        end

      end # class Compiled
    end # class Operand
  end # module Sequel
end # module Alf
