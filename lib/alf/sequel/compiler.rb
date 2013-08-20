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
          operand  = rw.operand
          ordering = to_sequel_ordering(operand, expr.ordering)
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
        elsif commons.size==0
          # (NOT) EXISTS (SELECT ... no join condition ...)
          rw.right.dataset.exists
        else
          # (NOT) EXISTS (SELECT ...)
          filter = Hash[rw.left.qualify(commons).zip(rw.right.qualify(commons))]
          filter = ::Sequel.expr filter
          filter = rw.right.filter(filter)
          filter.dataset.exists
        end
      end

      alias :on_minus :pass

      def on_page(expr)
        rewrite(expr){|rw|
          index, size, ordering  = expr.page_index, expr.page_size, expr.ordering
          operand, offset, limit = rw.operand, (index.abs - 1) * size, size
          ordering = to_sequel_ordering(operand, index >= 0 ? ordering : ordering.reverse)
          operand.order(*ordering).limit(offset , limit)
        }
      end

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

      def to_sequel_ordering(operand, ordering)
        ordering.to_a.map{|(col,dir)|
          ::Sequel.send(dir, operand.qualify(col))
        }
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
        rewrited = engine.call(rewrited) unless recognized?(rewrited)
        rewrited
      end

      def copy_and_apply(expr)
        if expr.is_a?(Algebra::Operator)
          expr.with_operands(*expr.operands.map{|op|
            apply(op).tap{|cog| cog.expr = expr }
          })
        else
          expr
        end
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