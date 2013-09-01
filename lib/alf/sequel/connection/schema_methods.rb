module Alf
  module Sequel
    class Connection
      module SchemaMethods

        def knows?(name)
          sequel_db.table_exists?(name)
        end

        def dataset(name)
          sequel_db[name]
        end

        def cog(name, expr = nil, opts = {})
          if as = opts[:alias]
            Cog.new(expr, self, dataset: dataset(:"#{name}___#{as}"), as: as)
          else
            Cog.new(expr, self, dataset: dataset(name))
          end
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

        def migrate!(opts)
          unless f = opts.migrations_folder
            raise Alf::ConfigError, "Migrations folder not set"
          end
          with_sequel_db do |db|
            ::Sequel.extension(:migration)
            ::Sequel::Migrator.apply(db, f)
          end
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
