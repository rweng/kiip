require 'spec_helper'

describe Kiip do
  it 'has a version number' do
    expect(Kiip::VERSION).not_to be nil
  end

  it 'has CONFIG defined' do
    expect(Kiip::CONFIG).not_to be nil
  end
end
