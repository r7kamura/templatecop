# frozen_string_literal: true

RSpec.describe Templatecop::PathFinder do
  describe '#call' do
    subject do
      described_class.new(
        default_patterns: default_patterns,
        patterns: patterns
      ).call
    end

    let(:default_patterns) do
      %w[**/*.slim]
    end

    let(:patterns) do
      raise NotImplementedError
    end

    context 'with normal file path' do
      let(:patterns) do
        %w[spec/fixtures/dummy.slim]
      end

      it 'returns expected file paths' do
        is_expected.to eq(
          [File.expand_path('spec/fixtures/dummy.slim')]
        )
      end
    end

    context 'with glob pattern' do
      let(:patterns) do
        %w[spec/**/*.slim]
      end

      it 'returns expected file paths' do
        is_expected.to eq(
          [File.expand_path('spec/fixtures/dummy.slim')]
        )
      end
    end

    context 'with directory path' do
      let(:patterns) do
        %w[spec/fixtures]
      end

      it 'excludes directies' do
        is_expected.to be_empty
      end
    end

    context 'with empty patterns' do
      let(:patterns) do
        []
      end

      it 'uses default patterns' do
        is_expected.to eq(
          [File.expand_path('spec/fixtures/dummy.slim')]
        )
      end
    end
  end
end
