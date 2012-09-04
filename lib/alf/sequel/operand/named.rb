module Alf
  module Sequel
    class Operand
      class Named < Operand
        include Alf::Iterator

        def initialize(connection, name)
          @connection = connection
          @name = name
        end
        attr_reader :connection, :name

        def main_scope
          connection.scope
        end

        def compile(as)
          dataset = connection.dataset(:"#{name}___#{as}")
          Operand::Compiled.new(connection, dataset, as)
        end

        ### Operand

        def keys
          connection.keys(name)
        end

        def heading
          connection.heading(name)
        end

        def insert(*args)
          connection.insert(name, *args)
        end

        def delete(*args)
          connection.delete(name, *args)
        end

        def update(*args)
          connection.update(name, *args)
        end

        def each
          dataset.each(&Proc.new)
        end

        def to_lispy
          name.to_s
        end

      private

        def dataset
          connection.dataset(name)
        end

      end # Named 
    end # class Operand
  end # module Sequel
end # module Alf
