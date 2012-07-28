module Alf
  module Sequel
    class Compiler < Lang::Compiler

      def initialize(context)
        @context = context
      end
      attr_reader :context

      def call(expr)
        compiled = super
        compiled = Sequel::Iterator.new(compiled) if compiled.is_a?(::Sequel::Dataset)
        compiled
      end

      def pass(expr)
        rewrite(expr)
      end
      alias :on_missing :pass

    ### non relational

      alias :on_autonum   :pass
      alias :on_coerce    :pass
      alias :on_defaults  :pass
      alias :on_generator :pass

      def on_clip(expr)
        rewrite(expr){|rw| rw.operand.select(*expr.stay_attributes) }
      end

      def on_compact(expr)
        rewrite(expr){|rw| rw.operand.distinct }
      end

      def on_sort(expr)
        rewrite(expr){|rw|
          ordering = expr.ordering.to_a.map{|(col,dir)| ::Sequel.send(dir, col) }
          rw.operand.order(*ordering)
        }
      end

    ### relational

      alias :on_extend :pass
      alias :on_group  :pass
      alias :on_infer_heading :pass

      def on_intersect(expr)
        rewrite(expr){|rw| rw.left.intersect(rw.right) }
      end

      def on_join(expr)
        rewrite(expr){|rw| rw.left.natural_join(rw.right) }
      end

      alias :on_matching :pass
      alias :on_minus :pass
      alias :on_not_matching :pass

      def on_project(expr)
        rewrite(expr){|rw|
          compiled = rw.operand.select(*expr.stay_attributes)
          compiled = compiled.distinct unless key_preserving?(expr){ false }
          compiled
        }
      end

      alias :on_quota :pass
      alias :on_rank  :pass

      def on_rename(expr)
        rewrite(expr){|rw| rw.operand.select(expr.complete_renaming.to_hash) }
      end

      def on_restrict(expr)
        rewrite(expr){|rw| rw.operand.filter(Predicate.new.call(rw.predicate)) }
      end

      alias :on_summarize :pass
      alias :on_ungroup :pass

      def on_union(expr)
        rewrite(expr){|rw| rw.left.union(rw.right) }
      end

      alias :on_unwrap :pass
      alias :on_wrap :pass

    private

      def var_ref?(expr)
        expr.is_a?(Operator::VarRef)
      end

      def key_preserving?(expr)
        expr.key_preserving?
      rescue NotSupportedError
        block_given? ? yield : raise
      end

    private

      def rewrite(expr)
        rewrited = copy_and_apply(expr)
        if block_given? and rewrited.operands.all?{|op| recognized?(op) }
          catch(:pass){ rewrited = yield(rewrited) }
        end
        unless recognized?(rewrited)
          rewrited = engine.call(rewrited)
        end
        rewrited
      end

      def recognized?(op)
        op.is_a?(::Sequel::Dataset)
      end

      def engine
        @engine ||= Engine::Compiler.new(context)
      end

    end # class Compiler
  end # module Sequel
end # module Alf
require_relative 'compiler/predicate'