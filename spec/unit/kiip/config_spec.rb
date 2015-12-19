require 'spec_helper'

describe Kiip::Config, type: :unit do
  subject { Kiip::Config.new({
                             }) }

  describe '.create_rc' do
    it 'copies the sample.yml to ~/.kiip.rc.yml' do
      expect(Command).to receive(:run).with(%r{^cp .+/kiip\.rc\.sample\.yml .+\.kiip\.rc\.yml$}).and_return true

      Kiip::Config.create_rc
    end
  end
end