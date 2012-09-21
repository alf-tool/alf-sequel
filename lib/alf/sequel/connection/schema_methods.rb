module Alf
  module Sequel
    class Connection
      module SchemaMethods

        def dataset(name)
          sequel_db[name]
        end

        def iterator(name)
          Operand::Named.new(self, name)
        end

        def heading(name)
          h = {}
          sequel_db.schema(name).each do |pair|
            column_name, info = pair
            h[column_name] = dbtype_to_ruby_type(info)
          end
          Heading.new(h)
        end

        def keys(name)
          # take the indexes
          indexes = sequel_db.indexes(name).
                              values.
                              select{|i| i[:unique] == true }.
                              map{|i| AttrList.coerce(i[:columns]) }.
                              sort{|a1, a2| a1.size <=> a2.size}

          # take single keys as well
          key = sequel_db.schema(name).
                          select{|(colname, colinfo)| colinfo[:primary_key] }.
                          map(&:first)
          indexes.unshift(AttrList.coerce(key)) unless key.empty?

          Keys.new(indexes)
        end

      private

        def dbtype_to_ruby_type(info)
          return Object unless info[:type]
          begin
            Kernel.eval(info[:type].to_s.capitalize)
          rescue NameError
            case info[:type]
            when :datetime then DateTime
            when :boolean  then Alf::Boolean
            else Object
            end
          end
        end

      end # module SchemaMethods
    end # module Connection
  end # module Sequel
end # module Alf
