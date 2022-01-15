# frozen_string_literal: true

require 'pathname'

module Templatecop
  # Collect file paths from given path patterns.
  class PathFinder
    DEFAULT_PATH_PATTERNS = %w[
      **/*.template
    ].freeze

    # @param [Array<String>] patterns Patterns normally given as CLI arguments (e.g. `["app/views/**/*.html.template"]`).
    def initialize(patterns:)
      @patterns = patterns
    end

    # @return [Array<String>]
    def call
      patterns.flat_map do |pattern|
        ::Pathname.glob(pattern).select(&:file?).map(&:to_s)
      end.uniq.sort
    end

    private

    # @return [Array<String>]
    def patterns
      if @patterns.empty?
        DEFAULT_PATH_PATTERNS
      else
        @patterns
      end
    end
  end
end
