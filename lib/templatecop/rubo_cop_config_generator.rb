# frozen_string_literal: true

require 'rubocop'

module Templatecop
  class RuboCopConfigGenerator
    DEFAULT_ADDITIONAL_CONFIG_PATH2 = '.rubocop.yml'

    # @param [String] additional_config_file_path
    def initialize(additional_config_file_path: nil)
      @additional_config_file_path = additional_config_file_path
    end

    # @return [RuboCop::Config]
    def call
      ::RuboCop::ConfigLoader.merge_with_default(merged_config, loaded_path)
    end

    private

    # @return [String]
    def loaded_path
      @additional_config_file_path || templatecop_default_config_file_path
    end

    # @return [RuboCop::Config]
    def merged_config
      ::RuboCop::Config.create(merged_config_hash, loaded_path)
    end

    # @return [Hash]
    def merged_config_hash
      result = templatecop_default_config
      result = ::RuboCop::ConfigLoader.merge(result, additional_config) if additional_config
      result
    end

    # @return [RuboCop::Config, nil]
    def additional_config
      if instance_variable_defined?(:@additional_config)
        @additional_config
      else
        @additional_config = \
          if @additional_config_file_path
            ::RuboCop::ConfigLoader.load_file(@additional_config_file_path)
          elsif ::File.exist?(default_additional_config_path1)
            ::RuboCop::ConfigLoader.load_file(default_additional_config_path1)
          elsif ::File.exist?(DEFAULT_ADDITIONAL_CONFIG_PATH2)
            ::RuboCop::ConfigLoader.load_file(DEFAULT_ADDITIONAL_CONFIG_PATH2)
          end
      end
    end

    # @return [RuboCop::Config]
    def templatecop_default_config
      ::RuboCop::ConfigLoader.load_file(templatecop_default_config_file_path)
    end

    # @return [String]
    def templatecop_default_config_file_path
      @templatecop_default_config_file_path ||= ::File.expand_path('../../default.yml', __dir__)
    end

    # @return [String]
    def default_additional_config_path1
      @default_additional_config_path1 ||= "#{self.class.name.split('::').first.downcase}.yml"
    end
  end
end
