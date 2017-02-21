# frozen_string_literal: true

module RuboCop
  module Formatter
    # This mix-in module provides string coloring methods for terminals.
    # It automatically disables coloring if coloring is disabled in the process
    # globally or the formatter's output is not a terminal.
    module Colorizable
      def colorizer_enabled
        @colorizer_enabled ||= begin
          if options[:color]
            true
          elsif options[:color] == false || !output.tty?
            false
          end
        end
      end

      def colorize(string, *args)
        @colorizer_enabled ? ColorizedString[string].colorize(*args) : string
      end

      [
        :black,
        :red,
        :green,
        :yellow,
        :blue,
        :magenta,
        :cyan,
        :white
      ].each do |color|
        define_method(color) do |string|
          colorize(string, color)
        end
      end
    end
  end
end
