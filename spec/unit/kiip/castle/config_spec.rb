require 'spec_helper'

describe Kiip::Castle::Config do
  let(:castle) { Kiip::Castle.new '/castle_path' }
  let(:config) { described_class.new castle }
  let(:ssh_task) { Kiip::Task.new(name: 'ssh', source: '~/.ssh', target: '/castle_path/home/ssh') }

  describe 'initialize' do
    it 'accepts a castle' do
      instance = described_class.new castle
      expect(instance).to be_an_instance_of described_class
    end
  end

  describe 'tasks' do
    it 'is a Hash' do
      expect(config.tasks).to be_an_instance_of Hash
    end
  end

  describe 'save!' do
    let(:tempfile){Tempfile.new('castle-config')}

    after do
      tempfile.delete
    end

    it 'writes tasks as yaml to path' do
      path = tempfile.path
      allow(config).to receive(:path).and_return path

      config.tasks['ssh'] = ssh_task

      config.save!

      expect(YAML.load_file(path)).to eq({
                                             "tasks" => {
                                                 "ssh" => {
                                                     "source" => "~/.ssh"
                                                 }
                                             }
                                         })

    end
  end
end