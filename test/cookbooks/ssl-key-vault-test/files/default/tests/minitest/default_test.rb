# frozen_string_literal: true

require File.expand_path('../support/helpers', __FILE__)

describe 'recipe[ssl-key-vault::default]' do
  it 'does run tests' do
    expect { 2 * 2 == 4 }
  end
end
