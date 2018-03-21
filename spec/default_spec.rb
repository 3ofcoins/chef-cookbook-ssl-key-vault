# frozen_string_literal: true

require 'chefspec'

describe 'ssl-key-vault::default' do
  let(:chef_run) { ChefSpec::ChefRunner.new.converge 'ssl-key-vault::default' }
  it 'should do something' do
    pending 'Your recipe examples go here.'
  end
end
