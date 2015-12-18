require 'spec_helper'

describe Kiip::Syncer, type: :unit do
  describe 'instance' do
    describe 'initialize' do
      let(:config_path) { fixture_path('sample.yml') }

      subject { Kiip::Syncer.new(config_path) }


      it 'creates a Kiip::Config' do
        expect(subject.config).to be_an_instance_of(Kiip::Config)
      end
    end
  end
end