# frozen_string_literal: true

require 'parallel'
require 'stringio'

module Templatecop
  # Run investigation and auto-correction.
  class Runner
    # @param [Boolean] autocorrect
    # @param [Boolean] debug
    # @param [Array<String>] file_paths
    # @param [Object] formatter
    # @param [RuboCop::Config] rubocop_config
    # @param [#call] ruby_extractor
    def initialize(
      autocorrect:,
      file_paths:,
      formatter:,
      rubocop_config:,
      ruby_extractor:,
      debug: false
    )
      @autocorrect = autocorrect
      @debug = debug
      @file_paths = file_paths
      @formatter = formatter
      @rubocop_config = rubocop_config
      @ruby_extractor = ruby_extractor
    end

    # @return [Array<RuboCop::Cop::Offense>]
    def call
      on_started
      result = run_in_parallel
      on_finished(result)
      result.flat_map do |(_, offenses)|
        offenses
      end
    end

    private

    # @param [String] file_path
    # @param [Array<Templatecop::Offense>] offenses
    # @param [String] source
    def correct(file_path:, offenses:, source:)
      rewritten_source = TemplateCorrector.new(
        file_path: file_path,
        offenses: offenses,
        source: source
      ).call
      ::File.write(file_path, rewritten_source)
    end

    # @param [Boolean] autocorrect
    # @param [Boolean] debug
    # @param [String] file_path
    # @param [String] rubocop_config
    # @param [String] source
    # @return [Array<Templatecop::Offense>]
    def investigate(
      autocorrect:,
      debug:,
      file_path:,
      rubocop_config:,
      source:
    )
      TemplateOffenseCollector.new(
        autocorrect: autocorrect,
        debug: debug,
        file_path: file_path,
        rubocop_config: rubocop_config,
        ruby_extractor: @ruby_extractor,
        source: source
      ).call
    end

    # @return [Hash]
    def run_in_parallel
      ::Parallel.map(@file_paths) do |file_path|
        offenses_per_file = []
        max_trials_count.times do
          on_file_started(file_path)
          source = ::File.read(file_path)
          offenses = investigate(
            autocorrect: @autocorrect,
            debug: @debug,
            file_path: file_path,
            rubocop_config: @rubocop_config,
            source: source
          )
          offenses_per_file |= offenses
          break if offenses.select(&:correctable?).empty?

          next unless @autocorrect

          correct(
            file_path: file_path,
            offenses: offenses,
            source: source
          )
        end
        on_file_finished(file_path, offenses_per_file)
        [file_path, offenses_per_file]
      end
    end

    # @return [Integer]
    def max_trials_count
      if @autocorrect
        7 # What a heuristic number.
      else
        1
      end
    end

    def on_started
      @formatter.started(@file_paths)
    end

    # @param [String] file_path
    def on_file_started(file_path)
      @formatter.file_started(file_path, {})
    end

    # @param [String] file_path
    # @param [Array<RuboCop::Cop::Offenses]
    def on_file_finished(file_path, offenses)
      @formatter.file_finished(file_path, offenses)
    end

    # We need to adjust @formatter's status (in silently)
    # because @formatter.on_file_* was called in child process, not in this process.
    # @param [Array] result
    def on_finished(result)
      original = @formatter.output
      @formatter.instance_variable_set(:@output, ::StringIO.new)
      result.each do |(file_path, offenses)|
        on_file_started(file_path)
        on_file_finished(file_path, offenses)
      end
      @formatter.instance_variable_set(:@output, original)

      @formatter.finished(@file_paths)
    end
  end
end
