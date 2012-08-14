module Alf
  module Sequel
    #
    # Specialization of Alg::Iterator to work on a Sequel dataset
    #
    class Iterator
      include Alf::Iterator

      # Creates an iterator instance
      def initialize(dataset, as = nil, context = nil)
        @dataset = dataset
        @as = as
        @context = context
      end
      attr_reader :dataset, :as, :context

      def main_scope
        context.scope
      end

      # (see Alf::Iterator#each)
      def each
        @dataset.each(&Proc.new)
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
        branch dataset.inner_join(other.dataset, cols, opts), opts[:table_alias]
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

      def branch(ds, as=self.as, context=self.context)
        Iterator.new ds, as, context
      end

    end # class Iterator
  end # module Sequel
end # module Alf
