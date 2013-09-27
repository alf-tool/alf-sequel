module Alf
  module Sequel
    class Translator < Sexpr::Processor

      def initialize(db)
        @db = db
      end
      attr_reader :db

      def on_with_exp(sexpr)
        dataset = apply(sexpr.select_exp)
        apply(sexpr.with_spec).each_pair do |name,subquery|
          dataset = dataset.with(name, subquery)
        end
        dataset
      end

      def on_with_spec(sexpr)
        sexpr.each_with_object({}){|child,hash|
          next if child == :with_spec
          hash[apply(child.table_name)] = apply(child.subquery)
        }
      end

      def on_set_operator(sexpr)
        left, right = apply(sexpr.left), apply(sexpr.right)
        left.send(sexpr.first, right, all: sexpr.all?, from_self: false)
      end
      alias :on_union     :on_set_operator
      alias :on_intersect :on_set_operator
      alias :on_except    :on_set_operator

      def on_select_exp(sexpr)
        dataset   = db.select(1)
        dataset   = dataset(apply(sexpr.from_clause)) if sexpr.from_clause
        #
        selection = apply(sexpr.select_list)
        predicate = apply(sexpr.predicate)       if sexpr.predicate
        order     = apply(sexpr.order_by_clause) if sexpr.order_by_clause
        limit     = apply(sexpr.limit_clause)    if sexpr.limit_clause
        offset    = apply(sexpr.offset_clause)   if sexpr.offset_clause
        #
        dataset   = dataset.select(*selection)
        dataset   = dataset.distinct             if sexpr.distinct?
        dataset   = dataset.where(predicate)     if predicate
        dataset   = dataset.order_by(*order)     if order
        dataset   = dataset.limit(limit, offset) if limit or offset
        dataset
      end

      def on_select_list(sexpr)
        sexpr.sexpr_body.map{|c| apply(c)}
      end

      def on_select_star(sexpr)
        ::Sequel.lit('*')
      end

      def on_select_item(sexpr)
        if sexpr.would_be_name == sexpr.as_name
          apply(sexpr.left)
        else
          ::Sequel.as(apply(sexpr.left), apply(sexpr.right))
        end
      end

      def on_qualified_name(sexpr)
        apply(sexpr.last).qualify(sexpr.qualifier)
      end

      def on_column_name(sexpr)
        ::Sequel.expr(sexpr.last.to_sym)
      end

      def on_from_clause(sexpr)
        apply(sexpr.table_spec)
      end

      def on_table_name(sexpr)
        ::Sequel.identifier(sexpr.last)
      end

      def on_cross_join(sexpr)
        left, right = apply(sexpr.left), apply(sexpr.right)
        dataset(left).cross_join(right)
      end

      def on_inner_join(sexpr)
        left, right = apply(sexpr.left), apply(sexpr.right)
        options = {qualify: false, table_alias: false}
        dataset(left).join_table(:inner, right, nil, options){|*args|
          apply(sexpr.predicate)
        }
      end

      def on_table_as(sexpr)
        ::Sequel.as(sexpr.table_name, sexpr.as_name)
      end

      def on_order_by_clause(sexpr)
        sexpr.sexpr_body.map{|c| apply(c)}
      end

      def on_order_by_term(sexpr)
        ::Sequel.send(sexpr.direction, apply(sexpr.qualified_name))
      end

      def on_limit_clause(sexpr)
        sexpr.last
      end

      def on_offset_clause(sexpr)
        sexpr.last
      end

    ### Predicate

      def on_identifier(sexpr)
        ::Sequel.identifier(sexpr.last)
      end

      def on_qualified_identifier(sexpr)
        ::Sequel.as(sexpr.qualifier, sexpr.name)
      end

      def on_tautology(sexpr)
        ::Sequel::SQL::BooleanConstant.new(true)
      end

      def on_contradiction(sexpr)
        ::Sequel::SQL::BooleanConstant.new(false)
      end

      def on_literal(sexpr)
        sexpr.last.nil? ? nil : ::Sequel.expr(sexpr.last)
      end

      def on_eq(sexpr)
        left, right = apply(sexpr.left), apply(sexpr.right)
        ::Sequel.expr(left => right)
      end

      def on_neq(sexpr)
        left, right = apply(sexpr.left), apply(sexpr.right)
        ~::Sequel.expr(left => right)
      end

      def on_dyadic_comp(sexpr)
        left, right = apply(sexpr.left), apply(sexpr.right)
        left.send(sexpr.operator_symbol, right)
      end
      alias :on_lt  :on_dyadic_comp
      alias :on_lte :on_dyadic_comp
      alias :on_gt  :on_dyadic_comp
      alias :on_gte :on_dyadic_comp

      def on_in(sexpr)
        left, right = apply(sexpr.identifier), sexpr.last
        right = apply(right) if sexpr.subquery?
        ::Sequel.expr(left => right)
      end

      def on_exists(sexpr)
        apply(sexpr.last).exists
      end

      def on_not(sexpr)
        ~apply(sexpr.last)
      end

      def on_and(sexpr)
        body = sexpr.sexpr_body
        body[1..-1].inject(apply(body.first)){|f,t| f & apply(t) }
      end

      def on_or(sexpr)
        body = sexpr.sexpr_body
        body[1..-1].inject(apply(body.first)){|f,t| f | apply(t) }
      end

    private

      def dataset(expr)
        return expr if ::Sequel::Dataset===expr
        db[expr]
      end

    end # class Translator
  end # module Sequel
end # module Alf
