module Alf
  module Sequel
    class Cog
      include Engine::Cog

      def initialize(expr, connection, opts)
        super(expr)
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

      def select(expr, attrs)
        branch expr, dataset: dataset.select(*qualify(attrs))
      end

      def rename(expr, attrs, opts)
        branch expr, dataset: dataset.select(*qualify(attrs)).from_self(opts),
                          as: opts[:alias]
      end

      def distinct(expr, *args, &bl)
        branch expr, dataset: dataset.distinct(*args, &bl)
      end

      def order(expr, *args, &bl)
        branch expr, dataset: dataset.order(*args, &bl)
      end

      def filter(expr, *args, &bl)
        branch expr, dataset: dataset.filter(*args, &bl)
      end

      def intersect(expr, other, opts={})
        branch expr, dataset: dataset.intersect(other.dataset, opts),
                          as: opts[:alias]
      end

      def join(expr, other, cols, opts={})
        join = dataset.inner_join(other.dataset, cols, :table_alias => opts[:alias])
        branch expr, dataset: join.from_self(opts),
                          as: opts[:alias]
      end

      def union(expr, other, opts={})
        branch expr, dataset: dataset.union(other.dataset, opts),
                          as: opts[:alias]
      end

      def limit(expr, *args, &bl)
        branch expr, dataset: dataset.limit(*args, &bl)
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

      def branch(expr, opts = {})
        Cog.new expr, connection, self.opts.merge(opts)
      end

      def to_s
        "Alf::Sequel::Cog|#{sql}"
      end

    end # class Operand
  end # module Sequel
end # module Alf
