# frozen_string_literal: true

RSpec.describe Templatecop::RubyOffenseCollector do
  describe '#call' do
    subject do
      described_class.new(
        autocorrect: false,
        file_path: 'dummy.slim',
        rubocop_config: Templatecop::RuboCopConfigGenerator.new(
          default_configuration_path: File.expand_path('../fixtures/default.yml', __dir__),
          forced_configuration_path: nil,
          implicit_configuration_paths: %w[.slimcop.yml .rubocop.yml]
        ).call,
        source: source
      ).call
    end

    let(:source) do
      <<~RUBY
        "a"
      RUBY
    end

    context 'with valid condition' do
      it 'returns expected offenses' do
        expect(subject).not_to be_empty
      end
    end

    context 'with rubocop:todo comment' do
      let(:source) do
        <<~RUBY
          "a" # rubocop:todo Style/StringLiterals
        RUBY
      end

      it 'excludes disabled offenses' do
        expect(subject).to be_empty
      end
    end

    context 'with rubocop:disable comment' do
      let(:source) do
        <<~RUBY
          "a" # rubocop:disable Style/StringLiterals
        RUBY
      end

      it 'excludes disabled offenses' do
        expect(subject).to be_empty
      end
    end

    context 'with rubocop:disable comment with missing cop enable directive' do
      let(:source) do
        <<~RUBY
          # rubocop:disable Style/StringLiterals
          "a"
        RUBY
      end

      it 'excludes disabled offenses' do
        expect(subject.size).to eq 1
        expect(subject.first.cop_name).to eq 'Lint/MissingCopEnableDirective'
      end
    end
  end
end
