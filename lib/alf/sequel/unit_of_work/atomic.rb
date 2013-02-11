module Alf
  module Sequel
    module UnitOfWork
      module Atomic

        def initialize(connection)
          @connection = connection
          @ran        = false
          @failure    = nil
        end
        attr_reader :connection, :failure

        def ran?
          @ran
        end

        def failed?
          not(@failure.nil?)
        end

        def run
          raise IllegalStateError, "Unit of work already ran" if ran?
          _run
          self
        rescue => ex
          @failure = ex
          raise
        ensure
          @ran = true
        end

      end # module Atomic
    end # module UnitOfWork
  end # module Sequel
end # module Alf
