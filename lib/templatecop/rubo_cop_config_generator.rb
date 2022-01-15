# frozen_string_literal: true

require 'rubocop'

module Templatecop
  # Generate RuboCop::Config.
  class RuboCopConfigGenerator
    # @param [String] default_configuration_path
    # @param [String, nil] forced_configuration_path
    # @param [Array<String>] implicit_configuration_paths
    def initialize(
      default_configuration_path:,
      forced_configuration_path:,
      implicit_configuration_paths:
    )
      @default_configuration_path = default_configuration_path
      @forced_configuration_path = forced_configuration_path
      @implicit_configuration_paths = implicit_configuration_paths
    end

    # @return [RuboCop::Config]
    def call
      ::RuboCop::ConfigLoader.merge_with_default(merged_config, loaded_path)
    end

    private

    # @return [String]
    def loaded_path
      @forced_configuration_path || implicit_configuration_path || @default_configuration_path
    end

    # @return [RuboCop::Config]
    def merged_config
      ::RuboCop::Config.create(merged_config_hash, loaded_path)
    end

    # @return [Hash]
    def merged_config_hash
      result = default_config
      result = ::RuboCop::ConfigLoader.merge(result, user_config) if user_config
      result
    end

    # @return [RuboCop::Config, nil]
    def user_config
      if instance_variable_defined?(:@user_config)
        @user_config
      else
        @user_config = \
          if @forced_configuration_path
            ::RuboCop::ConfigLoader.load_file(@forced_configuration_path)
          elsif (path = implicit_configuration_path)
            ::RuboCop::ConfigLoader.load_file(path)
          end
      end
    end

    # @return [RuboCop::Config]
    def default_config
      ::RuboCop::ConfigLoader.load_file(@default_configuration_path)
    end

    # @return [String, nil]
    def implicit_configuration_path
      if instance_variable_defined?(:@implicit_configuration_path)
        @implicit_configuration_path
      else
        @implicit_configuration_path = @implicit_configuration_paths.find do |path|
          ::File.exist?(path)
        end
      end
    end
  end
end
