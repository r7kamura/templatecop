# frozen_string_literal: true

require 'templatei'

module Templatecop
  # Extract Ruby codes from Template source.
  class RubyExtractor
    # @param [String, nil] file_path
    # @param [String] source
    def initialize(file_path:, source:)
      @file_path = file_path
      @source = source
    end

    # @return [Array<Hash>]
    def call
      ranges.map do |(begin_, end_)|
        clipped = RubyClipper.new(@source[begin_...end_]).call
        {
          code: clipped[:code],
          offset: begin_ + clipped[:offset]
        }
      end
    end

    private

    # @return [Array] Template AST, represented in S-expression.
    def ast
      ::Templatei::Filters::Interpolation.new.call(
        ::Templatei::Parser.new(file: @file_path).call(@source)
      )
    end

    # @return [Array<Array<Integer>>]
    def ranges
      result = []
      traverse(ast) do |begin_, end_|
        result << [begin_, end_]
      end
      result
    end

    def traverse(node, &block)
      return unless node.instance_of?(::Array)

      if node[0] == :templatei && node[1] == :position
        block.call(node[2], node[3])
      else
        node.each do |element|
          traverse(element, &block)
        end
      end
    end
  end
end
