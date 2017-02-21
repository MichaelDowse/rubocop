# frozen_string_literal: true

require 'spec_helper'

module RuboCop
  module Formatter
    describe Colorizable do
      let(:formatter_class) do
        Class.new(BaseFormatter) do
          include Colorizable
        end
      end

      let(:options) { {} }

      let(:formatter) do
        formatter_class.new(output, options)
      end

      let(:output) { double('output') }

      around do |example|
        original_state = ColorizedString.disable_colorization

        begin
          example.run
        ensure
          ColorizedString.disable_colorization == original_state
        end
      end

      describe '#colorize' do
        subject { formatter.colorize('foo', :red) }

        shared_examples 'does nothing' do
          it 'does nothing' do
            is_expected.to eq('foo')
          end
        end

        context 'when the global ColorizedString.disable_colorization is false' do
          before do
            ColorizedString.disable_colorization = false
          end

          context "and the formatter's output is a tty" do
            before do
              allow(output).to receive(:tty?).and_return(true)
            end

            it 'colorizes the passed string' do
              is_expected.to eq("\e[31mfoo\e[0m")
            end
          end

          context "and the formatter's output is not a tty" do
            before do
              allow(output).to receive(:tty?).and_return(false)
            end

            include_examples 'does nothing'
          end

          context 'and output is not a tty, but --color option was provided' do
            let(:options) { { color: true } }

            before do
              allow(output).to receive(:tty?).and_return(false)
            end

            it 'colorizes the passed string' do
              is_expected.to eq("\e[31mfoo\e[0m")
            end
          end
        end

        context 'when the global ColorizedString.disable_colorization is true' do
          before do
            ColorizedString.disable_colorization = true
          end

          context "and the formatter's output is a tty" do
            before do
              allow(output).to receive(:tty?).and_return(true)
            end

            include_examples 'does nothing'
          end

          context "and the formatter's output is not a tty" do
            before do
              allow(output).to receive(:tty?).and_return(false)
            end

            include_examples 'does nothing'
          end
        end
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
        describe "##{color}" do
          it "invokes #colorize(string, #{color}" do
            expect(formatter).to receive(:colorize).with('foo', color)
            formatter.send(color, 'foo')
          end
        end
      end
    end
  end
end
