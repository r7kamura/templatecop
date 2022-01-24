# frozen_string_literal: true

require 'forwardable'

require 'parser'
require 'rubocop'

module Templatecop
  class Offense
    extend ::Forwardable

    # @return [String]
    attr_reader :file_path

    # @return [Integer]
    attr_reader :offset

    delegate(
      %i[
        column
        column_length
        cop_name
        correctable?
        corrected_with_todo?
        corrected?
        corrector
        eql?
        hash
        highlighted_area
        line
        message
        real_column
        severity
      ] => :rubocop_offense_with_real_location
    )

    # @param [Integer] offset
    # @param [RuboCop::Cop::Offense] rubocop_offense
    # @param [String] source Template code.
    def initialize(file_path:, offset:, rubocop_offense:, source:)
      @file_path = file_path
      @offset = offset
      @rubocop_offense = rubocop_offense
      @source = source
    end

    # @return [Parser::Source::Range]
    def location
      @location ||= ::Parser::Source::Range.new(
        buffer,
        @rubocop_offense.location.begin_pos + @offset,
        @rubocop_offense.location.end_pos + @offset
      )
    end

    # @note For Parallel.
    # @return [Hash]
    def marshal_dump
      {
        begin_pos: @rubocop_offense.location.begin_pos,
        cop_name: @rubocop_offense.cop_name,
        end_pos: @rubocop_offense.location.end_pos,
        file_path: @file_path,
        message: @rubocop_offense.message.dup.force_encoding(::Encoding::UTF_8).scrub,
        offset: @offset,
        severity: @rubocop_offense.severity.to_s,
        source: @source,
        status: @rubocop_offense.status
      }
    end

    # @note For Parallel.
    # @param [Hash] hash
    def marshal_load(hash)
      @file_path = hash[:file_path]
      @offset = hash[:offset]
      @rubocop_offense = ::RuboCop::Cop::Offense.new(
        hash[:severity],
        ::Parser::Source::Range.new(
          ::Parser::Source::Buffer.new(
            @file_path,
            source: @source
          ),
          hash[:begin_pos],
          hash[:end_pos]
        ),
        hash[:message],
        hash[:cop_name],
        hash[:status].to_sym
      )
      @source = hash[:source]
    end

    private

    # @return [Parser::Source::Buffer]
    def buffer
      ::Parser::Source::Buffer.new(
        file_path,
        source: @source
      )
    end

    # @return [RuboCop::Cop::Offense]
    def rubocop_offense_with_real_location
      ::RuboCop::Cop::Offense.new(
        @rubocop_offense.severity.name,
        location,
        @rubocop_offense.message,
        @rubocop_offense.cop_name,
        @rubocop_offense.status,
        @rubocop_offense.corrector
      )
    end
  end
end
