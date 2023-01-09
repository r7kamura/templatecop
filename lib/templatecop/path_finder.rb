# frozen_string_literal: true

require 'pathname'
require 'set'

module Templatecop
  # Collect file paths from given path patterns.
  class PathFinder
    # @param [Array<String>] default_patterns
    # @param [Array<String>] patterns Patterns normally given as CLI arguments (e.g. `["app/views/**/*.html.template"]`).
    def initialize(
      default_patterns:,
      exclude_patterns:,
      patterns:
    )
      @default_patterns = default_patterns
      @exclude_patterns = exclude_patterns || []
      @patterns = patterns
    end

    # @return [Array<String>]
    def call
      matching_paths(patterns) do |path|
        !excluded?(path)
      end.sort
    end

    private

    # @return [Set<String>]
    def excluded
      @excluded ||= matching_paths(@exclude_patterns)
    end

    # @return [TrueClass,FalseClass]
    def excluded?(path)
      excluded.include?(path)
    end

    # @return [Set<String>]
    def matching_paths(patterns, &block)
      patterns.each_with_object(Set.new) do |pattern, set|
        ::Pathname.glob(pattern) do |pathname|
          next unless pathname.file?

          path = pathname.expand_path.to_s
          set.add(path) if block.nil? || block.call(path)
        end
      end
    end

    # @return [Array<String>]
    def patterns
      return @default_patterns if @patterns.empty?

      @patterns.map do |pattern|
        next pattern unless File.directory?(pattern)

        @default_patterns.map do |default|
          File.join(pattern, default)
        end.flatten
      end
    end
  end
end
