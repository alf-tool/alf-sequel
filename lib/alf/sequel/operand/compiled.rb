module Alf
  module Sequel
    class Operand
      class Compiled < Operand
        include Alf::Iterator

        def initialize(connection, opts)
          @connection = connection
          @opts = opts
        end
        attr_reader :connection, :opts

        def as;         opts[:as];         end
        def dataset;    opts[:dataset];    end

      ### Iterator

        def main_scope
          connection.scope
        end

        def each
          dataset.each(&Proc.new)
        end

      ### Delegation to Dataset, that is, facade over ::Sequel itself

        def select(attrs)
          branch dataset: dataset.select(*qualify(attrs))
        end

        def rename(attrs, opts)
          branch dataset: dataset.select(qualify(attrs)).from_self(opts),
                      as: opts[:alias]
        end

        def distinct(*args, &bl)
          branch dataset: dataset.distinct(*args, &bl)
        end

        def order(*args, &bl)
          branch dataset: dataset.order(*args, &bl)
        end

        def filter(*args, &bl)
          branch dataset: dataset.filter(*args, &bl)
        end

        def intersect(other, opts={})
          branch dataset: dataset.intersect(other.dataset, opts),
                      as: opts[:alias]
        end

        def join(other, cols, opts={})
          join = dataset.inner_join(other.dataset, cols, :table_alias => opts[:alias])
          branch dataset: join.from_self(opts),
                      as: opts[:alias]
        end

        def union(other, opts={})
          branch dataset: dataset.union(other.dataset, opts),
                      as: opts[:alias]
        end

      ### compilation tools

        def sql
          dataset.sql
        end

        def qualify(attributes)
          return attributes unless as
          case attributes
          when Symbol
            ::Sequel.qualify(as, attributes)
          when Hash
            Hash[attributes.each_pair.map{|k,v| [::Sequel.qualify(as, k), v] }]
          else
            attributes.map{|a| ::Sequel.qualify(as, a)}
          end
        end

      private

        def branch(opts = {})
          Compiled.new connection, self.opts.merge(opts)
        end

      end # class Compiled
    end # class Operand
  end # module Sequel
end # module Alf
