# frozen_string_literal: true

require 'optparse'
require 'rubocop'

module Templatecop
  # Provide command-line interface.
  # Inherit me, and call it from your executable.
  # @example
  #   Yourcop::Cli.new(@argv).call
  class Cli
    def initialize(argv)
      @argv = argv.dup
    end

    def call
      options = parse_options!
      formatter = ::RuboCop::Formatter::ProgressFormatter.new($stdout, color: options[:color])
      rubocop_config = RuboCopConfigGenerator.new(additional_config_file_path: options[:additional_config_file_path]).call
      file_paths = PathFinder.new(patterns: @argv).call

      offenses = Runner.new(
        auto_correct: options[:auto_correct],
        file_paths: file_paths,
        formatter: formatter,
        rubocop_config: rubocop_config
      ).call

      exit(offenses.empty? ? 0 : 1)
    end

    private

    # @return [String]
    def first_default_configuration_path
      "#{executable_name}.yml"
    end

    # @return [String]
    def executable_name
      self.class.name.split('::').first.downcase
    end

    # @return [Hash]
    def parse_options!
      options = {}
      parser = ::OptionParser.new
      parser.banner = "Usage: #{executable_name} [options] [file1, file2, ...]"
      parser.version = VERSION
      parser.on('-a', '--auto-correct', 'Auto-correct offenses.') do
        options[:auto_correct] = true
      end
      parser.on('-c', '--config=', "Specify configuration file. (default: #{first_default_configuration_path} or .rubocop.yml)") do |file_path|
        options[:additional_config_file_path] = file_path
      end
      parser.on('--[no-]color', 'Force color output on or off.') do |value|
        options[:color] = value
      end
      parser.parse!(@argv)
      options
    end
  end
end
