# frozen_string_literal: true

require 'rubocop'

module Templatecop
  # Collect RuboCop offenses from Ruby code.
  class RubyOffenseCollector
    # @param [Boolean] autocorrect
    # @param [Boolean] debug
    # @param [String] file_path
    # @param [RuboCop::Config] rubocop_config
    # @param [String] source
    def initialize(
      autocorrect:,
      file_path:,
      rubocop_config:,
      source:,
      debug: false
    )
      @autocorrect = autocorrect
      @debug = debug
      @file_path = file_path
      @rubocop_config = rubocop_config
      @source = source
    end

    # @return [Array<RuboCop::Cop::Offense>]
    def call
      # Skip if invalid syntax Ruby code is given. (e.g. "- if a?")
      return [] unless rubocop_processed_source.valid_syntax?

      rubocop_team.investigate(rubocop_processed_source).offenses.reject(&:disabled?)
    end

    private

    # @return [RuboCop::Cop::Registry]
    def registry
      @registry ||= begin
        all_cops = if ::RuboCop::Cop::Registry.respond_to?(:all)
                     ::RuboCop::Cop::Registry.all
                   else
                     ::RuboCop::Cop::Cop.all
                   end

        ::RuboCop::Cop::Registry.new(all_cops)
      end
    end

    # @return [RuboCop::ProcessedSource]
    def rubocop_processed_source
      @rubocop_processed_source ||= ::RuboCop::ProcessedSource.new(
        @source,
        @rubocop_config.target_ruby_version,
        @file_path
      ).tap do |processed_source|
        processed_source.config = @rubocop_config if processed_source.respond_to?(:config)
        processed_source.registry = registry if processed_source.respond_to?(:registry)
      end
    end

    # @return [RuboCop::Cop::Team]
    def rubocop_team
      ::RuboCop::Cop::Team.new(
        registry,
        @rubocop_config,
        auto_correct: @autocorrect, # DEPRECATED
        autocorrect: @autocorrect,
        debug: @debug,
        display_cop_names: true,
        extra_details: true,
        stdin: ''
      )
    end
  end
end
