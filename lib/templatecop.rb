# frozen_string_literal: true

require_relative 'templatecop/version'

module Templatecop
  autoload :Cli, 'templatecop/cli'
  autoload :Offense, 'templatecop/offense'
  autoload :PathFinder, 'templatecop/path_finder'
  autoload :RuboCopConfigGenerator, 'templatecop/rubo_cop_config_generator'
  autoload :RubyClipper, 'templatecop/ruby_clipper'
  autoload :RubyExtractor, 'templatecop/ruby_extractor'
  autoload :RubyOffenseCollector, 'templatecop/ruby_offense_collector'
  autoload :Runner, 'templatecop/runner'
  autoload :TemplateCorrector, 'templatecop/template_corrector'
  autoload :TemplateOffenseCollector, 'templatecop/template_offense_collector'
end
