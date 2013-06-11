module Alf
  module Sequel
    class Cog
      include Engine::Cog

      def initialize(connection, opts)
        @connection = connection
        @opts = opts
      end
      attr_reader :connection, :opts

      def as;         opts[:as];         end
      def dataset;    opts[:dataset];    end

    ### Cog

      def to_relation
        Relation.coerce(to_a)
      end

      def each
        dataset.each(&Proc.new)
      end

    ### Delegation to Dataset, that is, facade over ::Sequel itself

      def select(attrs)
        branch dataset: dataset.select(*qualify(attrs))
      end

      def rename(attrs, opts)
        branch dataset: dataset.select(*qualify(attrs)).from_self(opts),
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
          attributes.map{|k,v| ::Sequel.as(::Sequel.qualify(as, k), v) }
        else
          attributes.map{|a| ::Sequel.qualify(as, a)}
        end
      end

      def branch(opts = {})
        Cog.new connection, self.opts.merge(opts)
      end

      def to_s
        "Alf::Sequel::Cog|#{sql}"
      end

    end # class Operand
  end # module Sequel
end # module Alf
