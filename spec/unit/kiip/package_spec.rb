require 'spec_helper'

describe Kiip::Package, type: :unit do
  let(:repository) { Kiip::Repository.new path: '/path/to/repo' }
  let(:package) { described_class.new name: 'ssh', repository: repository }
  let(:task_double) { double('task', exec!: nil) }
  let(:target){ "/path/to/repo/ssh/#{described_class.encode('~/.ssh')}" }

  before do
    allow(package).to receive(:content).and_return [described_class.encode('~/.ssh')]
  end

  describe '#sync!' do
    subject { package.sync! }

    it 'creates a sync task' do
      expect(Kiip::Tasks::SymlinkTask).to receive(:new).with(name: 'task-name', source: '~/.ssh', target: target).and_return(task_double)

      subject

      expect(task_double).to have_received(:exec!)
    end
  end

  describe '#track ~/.ssh' do
    subject { package.track '~/.ssh' }

    before do
      allow(Kiip::Tasks::SymlinkTask).to receive(:new).with(name: 'task-name', source: '~/.ssh', target: target).and_return task_double
    end

    it 'executes a symlink task' do
      subject
      expect(Kiip::Tasks::SymlinkTask).to have_received(:new).with(name: 'task-name', source: '~/.ssh', target: target)
      expect(task_double).to have_received :exec!
    end
  end
end