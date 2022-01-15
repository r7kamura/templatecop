# frozen_string_literal: true

require 'parser'
require 'rubocop/cop/legacy/corrector'

module Templatecop
  # Apply auto-corrections to Template file.
  class TemplateCorrector
    # @param [String] file_path
    # @param [Array<Templatecop::Offense>] offenses
    # @param [String] source
    def initialize(file_path:, offenses:, source:)
      @file_path = file_path
      @offenses = offenses
      @source = source
    end

    # @return [String] Rewritten Template code.
    def call
      ::RuboCop::Cop::Legacy::Corrector.new(source_buffer, corrections).rewrite
    end

    private

    # @return [Array<Proc>]
    def corrections
      @offenses.select(&:corrector).map do |offense|
        lambda do |corrector|
          corrector.import!(offense.corrector, offset: offense.offset)
        end
      end
    end

    # @return [Parser::Source::Buffer]
    def source_buffer
      ::Parser::Source::Buffer.new(
        @file_path,
        source: @source
      )
    end
  end
end
