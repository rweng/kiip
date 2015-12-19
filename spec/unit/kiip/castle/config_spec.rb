require 'spec_helper'

describe Kiip::Castle::Config, type: :unit do
  let(:castle) { Kiip::Castle.new '/castle_path' }
  let(:config) { described_class.new castle }
  let(:ssh_package) { Kiip::Package.new(name: 'ssh', source: '~/.ssh') }
  let(:instance) { described_class.new castle }
  let(:tempfile) { Tempfile.new('castle-config') }

  after do
    tempfile.delete
  end

  describe 'initialize' do
    it 'accepts a castle' do
      expect(instance).to be_an_instance_of described_class
    end
  end

  describe '#load!' do
    it 'sets the tasks based in the config file' do
      allow(instance).to receive(:path).and_return fixture_path('sample_castle_config.yml')
      instance.load!

      expect(instance.packages).to match({'ssh' => an_instance_of(Kiip::Package)})
    end
  end

  describe 'packages' do
    it 'is a Hash' do
      expect(config.packages).to be_an_instance_of Hash
    end
  end

  describe 'save!' do
    it 'writes packages as yaml to path' do
      path = tempfile.path
      allow(config).to receive(:path).and_return path

      config.packages['ssh'] = ssh_package

      config.save!

      expect(YAML.load_file(path)).to eq({
                                             "packages" => {
                                                 "ssh" => {
                                                     "source" => "~/.ssh"
                                                 }
                                             }
                                         })

    end
  end
end