# frozen_string_literal: true

require 'rubocop'
require 'slimcop'
require 'stringio'

RSpec.describe Templatecop::Runner do
  describe '#call' do
    subject do
      described_class.new(
        autocorrect: false,
        file_paths: file_paths,
        formatter: formatter,
        rubocop_config: rubocop_config,
        ruby_extractor: ruby_extractor
      ).call
    end

    let(:file_paths) do
      %w[spec/fixtures/dummy.slim]
    end

    let(:formatter) do
      RuboCop::Formatter::ProgressFormatter.new(
        io,
        color: false
      )
    end

    let(:io) do
      StringIO.new
    end

    let(:rubocop_config) do
      RuboCop::ConfigLoader.default_configuration
    end

    let(:ruby_extractor) do
      Slimcop::RubyExtractor
    end

    it do
      is_expected.not_to be_empty
    end
  end
end
