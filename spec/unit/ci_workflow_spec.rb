# frozen_string_literal: true

require 'spec_helper'
require 'yaml'

describe 'unit test workflow' do
  let(:workflow) { YAML.load_file(File.expand_path('../../.github/workflows/test.yml', __dir__)) }
  let(:test_job) { workflow.fetch('jobs').fetch('test') }

  it 'requires Ruby 4.0 on the same matrix as the versions the project still claims' do
    expect(test_job.dig('strategy', 'matrix', 'ruby')).to eq(
      ['3.0', '3.1', '3.2', '3.3', '3.4', '4.0']
    )
  end

  it 'fails the workflow when Ruby 4.0 fails' do
    expect(test_job['continue-on-error']).to be_nil
    expect(workflow.fetch('jobs').keys).to eq(['test'])
  end

  it 'stops a stuck matrix cell before it holds a runner for hours' do
    expect(test_job['timeout-minutes']).to eq(20)
  end
end
