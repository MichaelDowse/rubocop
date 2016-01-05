# encoding: utf-8

module RuboCop
  module Cop
    module Performance
      # This cop identifies use of `Regexp#match` or `String#match in a context
      # where the integral return value of `=~` would do just as well.
      #
      # @example
      #   @bad
      #   do_something if str.match(/regex/)
      #   while regex.match('str')
      #     do_something
      #   end
      #
      #   @good
      #   method(str.match(/regex/))
      #   return regex.match('str')
      class RedundantMatch < Cop
        MSG = 'Use `=~` in places where the `MatchData` returned by ' \
              '`#match` will not be used.'

        # 'match' is a fairly generic name, so we don't flag it unless we see
        # a string or regexp literal on one side or the other
        def_node_matcher :match_call?, <<-END
          {(send {str regexp} :match _)
           (send _ :match {str regexp})}
        END

        def_node_matcher :only_truthiness_matters?, <<-END
          ^({if while until case while_post until_post} equal?(%0) ...)
        END

        def on_send(node)
          return unless match_call?(node) &&
                        (!node.value_used? || only_truthiness_matters?(node))
          add_offense(node, :expression, MSG)
        end

        def autocorrect(node)
          # Regexp#match can take a second argument, but this cop doesn't
          # register an offense in that case
          receiver, _method, arg = *node
          new_source = receiver.source + ' =~ ' + arg.source
          ->(corrector) { corrector.replace(node.source_range, new_source) }
        end
      end
    end
  end
end