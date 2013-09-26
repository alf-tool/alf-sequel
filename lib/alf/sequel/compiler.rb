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
          expr.connection.cog(expr.name, expr, :alias => next_alias)
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
          rw.operand.select(expr, expr.stay_attributes)
        }
      end

      def on_compact(expr)
        rewrite(expr){|rw|
          rw.operand.distinct(expr)
        }
      end

      def on_sort(expr)
        rewrite(expr){|rw|
          operand  = rw.operand
          ordering = to_sequel_ordering(operand, expr.ordering)
          operand.order(expr, *ordering)
        }
      end

    ### relational

      alias :on_extend :pass

      def on_frame(expr)
        rewrite(expr){|rw|
          offset, limit, ordering  = expr.offset, expr.limit, expr.total_ordering
          operand  = rw.operand
          ordering = to_sequel_ordering(operand, ordering)
          operand.order(expr, *ordering).limit(expr, limit, offset)
        }
      end

      alias :on_group  :pass
      alias :on_infer_heading :pass

      def on_intersect(expr)
        rewrite(expr){|rw|
          rw.left.intersect(expr, rw.right, {:alias => next_alias})
        }
      end

      def on_join(expr)
        rewrite(expr){|rw|
          rw.left.join(expr, rw.right, expr.common_attributes.to_a, {:alias => next_alias})
        }
      end

      def on_matching(expr)
        rewrite(expr) do |rw|
          rw.left.filter(expr, matching2filter(expr, rw))
        end
      end

      def on_not_matching(expr)
        rewrite(expr) do |rw|
          rw.left.filter(expr, ~matching2filter(expr, rw))
        end
      end

      def matching2filter(expr, rw)
        commons = expr.common_attributes.to_a
        if commons.size==1
          # (NOT) IN (SELECT ...)
          pred = ::Alf::Predicate.in(commons.first, rw.right.select(expr, commons).dataset)
          Predicate.new(:qualifier => rw.left.as).call(pred)
        elsif commons.size==0
          # (NOT) EXISTS (SELECT ... no join condition ...)
          rw.right.dataset.exists
        else
          # (NOT) EXISTS (SELECT ...)
          filter = Hash[rw.left.qualify(commons).zip(rw.right.qualify(commons))]
          filter = ::Sequel.expr filter
          filter = rw.right.filter(expr, filter)
          filter.dataset.exists
        end
      end

      alias :on_minus :pass

      def on_page(expr)
        rewrite(expr){|rw|
          index, size, ordering  = expr.page_index, expr.page_size, expr.total_ordering
          operand, offset, limit = rw.operand, (index.abs - 1) * size, size
          ordering = to_sequel_ordering(operand, index >= 0 ? ordering : ordering.reverse)
          operand.order(expr, *ordering).limit(expr, offset , limit)
        }
      end

      def on_project(expr)
        rewrite(expr){|rw|
          compiled = rw.operand.select(expr, expr.stay_attributes)
          compiled = compiled.distinct(expr) unless key_preserving?(expr){ false }
          compiled
        }
      end

      alias :on_quota :pass
      alias :on_rank  :pass

      def on_rename(expr)
        rewrite(expr){|rw|
          rw.operand.rename(expr, expr.complete_renaming.to_hash, :alias => next_alias)
        }
      end

      def on_restrict(expr)
        rewrite(expr){|rw|
          filter = Predicate.new(:qualifier => rw.operand.as).call(rw.predicate)
          rw.operand.filter(expr, filter)
        }
      end

      alias :on_summarize :pass
      alias :on_ungroup :pass

      def on_union(expr)
        rewrite(expr){|rw|
          rw.left.union(expr, rw.right, :alias => next_alias)
        }
      end

      alias :on_unwrap :pass
      alias :on_wrap :pass

    private

      def to_sequel_ordering(operand, ordering)
        ordering.to_a.map{|(sel,dir)|
          raise NotSupportedError if sel.composite?
          ::Sequel.send(dir, operand.qualify(sel.outcoerce))
        }
      end

      def key_preserving?(expr)
        expr.key_preserving?
      rescue NotSupportedError
        block_given? ? yield : raise
      end

    private

      def rewrite(expr)
        # copy and apply on expr. the result is the same expression, but
        # with cogs instead of operands
        rewritten = copy_and_apply(expr)

        # Continue compilation process provided all operands are recognized.
        if block_given? and rewritten.operands.all?{|op| recognized?(op) }
          # Compilation of predicates may throw a pass
          catch(:pass){
            rewritten = yield(rewritten)
          }
        end

        # If the result is itself recognized, proceed
        # Otherwise, give a change to the upper-stage compiler with a proxy
        if recognized?(rewritten)
          rewritten
        else
          operands = rewritten.operands.map{|op|
            Algebra::Operand::Proxy.new(op)
          }
          rewritten = rewritten.with_operands(*operands)
          engine.call(rewritten)
        end
      end

      def recognized?(op)
        op.is_a?(Cog)
      end

      def engine
        @engine ||= Alf::Compiler::Default.new
      end

    end # class Compiler
  end # module Sequel
end # module Alf
require_relative 'compiler/predicate'