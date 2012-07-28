module Alf
  module Sequel
    #
    # Specialization of Alg::Iterator to work on a Sequel dataset
    #
    class Iterator
      include Alf::Iterator

      # Creates an iterator instance
      def initialize(dataset)
        @dataset = dataset
      end
      attr_reader :dataset

      # (see Alf::Iterator#each)
      def each
        @dataset.each(&Proc.new)
      end

      def sql
        dataset.sql
      end

    end # class Iterator
  end # module Sequel
end # module Alf
