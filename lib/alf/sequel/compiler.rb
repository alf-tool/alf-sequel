module Alf
  module Sequel
    class Compiler < Algebra::Compiler

      def pass(expr)
        rewrite(expr)
      end
      alias :on_missing :pass

      def next_alias
        @as ||= 0
        :"t#{@as += 1}"
      end

      def on_leaf_operand(expr)
        if Algebra::Operand::Named===expr
          expr.connection.cog(expr.name, :alias => next_alias)
        else
          expr.to_cog
        end
      end

    ### non relational

      alias :on_autonum   :pass
      alias :on_coerce    :pass
      alias :on_defaults  :pass
      alias :on_generator :pass

      def on_clip(expr)
        rewrite(expr){|rw|
          rw.operand.select(expr.stay_attributes)
        }
      end

      def on_compact(expr)
        rewrite(expr){|rw|
          rw.operand.distinct
        }
      end

      def on_sort(expr)
        rewrite(expr){|rw|
          operand = rw.operand
          ordering = expr.ordering.to_a.map{|(col,dir)|
            ::Sequel.send(dir, operand.qualify(col))
          }
          operand.order(*ordering)
        }
      end

    ### relational

      alias :on_extend :pass
      alias :on_group  :pass
      alias :on_infer_heading :pass

      def on_intersect(expr)
        rewrite(expr){|rw|
          rw.left.intersect(rw.right, :alias => next_alias)
        }
      end

      def on_join(expr)
        rewrite(expr){|rw|
          rw.left.join(rw.right, expr.common_attributes.to_a, :alias => next_alias)
        }
      end

      def on_matching(expr)
        rewrite(expr) do |rw|
          rw.left.filter(matching2filter(expr, rw))
        end
      end

      def on_not_matching(expr)
        rewrite(expr) do |rw|
          rw.left.filter(~matching2filter(expr, rw))
        end
      end

      def matching2filter(expr, rw)
        commons = expr.common_attributes.to_a
        if commons.size==1
          # (NOT) IN (SELECT ...)
          pred = ::Alf::Predicate.in(commons.first, rw.right.select(commons).dataset)
          Predicate.new(:qualifier => rw.left.as).call(pred)
        else
          # (NOT) EXISTS (SELECT ...)
          filter = Hash[rw.left.qualify(commons).zip(rw.right.qualify(commons))]
          filter = ::Sequel.expr filter
          filter = rw.right.filter(filter)
          filter.dataset.exists
        end
      end

      alias :on_minus :pass

      def on_project(expr)
        rewrite(expr){|rw|
          compiled = rw.operand.select(expr.stay_attributes)
          compiled = compiled.distinct unless key_preserving?(expr){ false }
          compiled
        }
      end

      alias :on_quota :pass
      alias :on_rank  :pass

      def on_rename(expr)
        rewrite(expr){|rw|
          rw.operand.rename(expr.complete_renaming.to_hash, :alias => next_alias)
        }
      end

      def on_restrict(expr)
        rewrite(expr){|rw|
          filter = Predicate.new(:qualifier => rw.operand.as).call(rw.predicate)
          rw.operand.filter(filter)
        }
      end

      alias :on_summarize :pass
      alias :on_ungroup :pass

      def on_union(expr)
        rewrite(expr){|rw|
          rw.left.union(rw.right, :alias => next_alias)
        }
      end

      alias :on_unwrap :pass
      alias :on_wrap :pass

    private

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
        rewrited = engine.call(rewrited) unless recognized?(rewrited)
        rewrited
      end

      def recognized?(op)
        op.is_a?(Cog)
      end

      def engine
        @engine ||= Engine::Compiler.new
      end

    end # class Compiler
  end # module Sequel
end # module Alf
require_relative 'compiler/predicate'