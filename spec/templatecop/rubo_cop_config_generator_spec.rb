# frozen_string_literal: true

RSpec.describe Templatecop::RuboCopConfigGenerator do
  describe '#call' do
    subject do
      described_class.new(
        default_configuration_path: default_configuration_path,
        forced_configuration_path: forced_configuration_path,
        implicit_configuration_paths: implicit_configuration_paths
      ).call
    end

    let(:default_configuration_path) do
      File.expand_path('../fixtures/default.yml', __dir__)
    end

    let(:forced_configuration_path) do
      nil
    end

    let(:implicit_configuration_paths) do
      []
    end

    context 'with valid condition' do
      it do
        is_expected.to be_a(RuboCop::Config)
      end
    end

    context 'with existent implicit_configuration_paths' do
      let(:implicit_configuration_paths) do
        %w[.rubocop.yml]
      end

      it do
        is_expected.to be_a(RuboCop::Config)
      end
    end

    context 'with non-existent implicit_configuration_paths' do
      let(:implicit_configuration_paths) do
        %w[non_existent.yml]
      end

      it do
        is_expected.to be_a(RuboCop::Config)
      end
    end

    context 'with non-existent forced_configuration_path' do
      let(:forced_configuration_path) do
        'non_existent.yml'
      end

      it do
        expect { subject }.to raise_error(RuboCop::ConfigNotFoundError)
      end
    end
  end
end
