require 'spec_helper'

describe Kiip::Config, type: :unit do
  subject{ Kiip::Config.new YAML::load_file(fixture_path('sample.yml')) }

  describe '#definitions' do
    it 'returns an array of Kiip::Definition' do
      expect(subject.tasks).to match [an_instance_of(Kiip::Task)]
    end
  end

  describe '.create_rc' do
    it 'copies the sample.yml to ~/.kiip.rc.yml' do
      expect(Command).to receive(:run).with(%r{^cp .+/kiip\.rc\.sample\.yml .+\.kiip\.rc\.yml$}).and_return true

      Kiip::Config.create_rc
    end
  end
end