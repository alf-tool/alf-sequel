module Alf
  module Sequel
    #
    # Specialization of Alg::Iterator to work on a Sequel dataset
    #
    class Iterator
      include Alf::Iterator

      # Creates an iterator instance
      def initialize(dataset, as = nil)
        @dataset = dataset
        @as = as
      end
      attr_reader :dataset, :as

      # (see Alf::Iterator#each)
      def each
        @dataset.each(&Proc.new)
      end

      ### Delegation to Dataset, that is, facade over ::Sequel itself

      def select(attributes)
        attributes = qualify(attributes)
        case attributes
        when Hash
          Iterator.new dataset.select(attributes), as
        else
          Iterator.new dataset.select(*attributes), as
        end
      end

      def distinct(*args, &bl)
        Iterator.new dataset.distinct(*args, &bl), as
      end

      def order(*args, &bl)
        Iterator.new dataset.order(*args, &bl), as
      end

      def filter(*args, &bl)
        Iterator.new dataset.filter(*args, &bl), as
      end

      def intersect(other, opts={})
        Iterator.new dataset.intersect(other.dataset, opts), opts[:alias]
      end

      def join(other, cols, opts={})
        Iterator.new dataset.inner_join(other.dataset, cols, opts), opts[:table_alias]
      end

      def union(other, opts={})
        Iterator.new dataset.union(other.dataset, opts), opts[:alias]
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

    end # class Iterator
  end # module Sequel
end # module Alf
