require 'spec_helper'

describe Kiip::Tasks::SymlinkTask, type: :unit do

  let(:source) { '~/.ssh' }
  let(:target) { '~/Drobox/kiip/home/ssh' }

  let(:instance) { described_class.new(
      name: 'def_name',
      source: source,
      target: target,
  ) }

  before do
    allow(FileUtils).to receive(:symlink).with(source, target)
  end

  describe 'sync!' do
    subject { instance.sync! }

    context '(when source does not exist)' do
      before do
        allow(File).to receive(:exists?).with(instance.source).and_return false
      end

      it 'recreates the symlink' do
        expect(FileUtils).to receive(:symlink).with(instance.source, instance.target) {}

        subject
      end
    end

    context '(when source is already the correct link)' do
      before do
        allow(File).to receive(:exists?).and_return true
        allow(File).to receive(:symlink?).with(source).and_return true
        allow(File).to receive(:readlink).with(source).and_return target
      end

      it 'does nothing' do
        subject
        expect(FileUtils).not_to have_received(:symlink)
      end
    end

    context '(when source does exist)' do
      before do
        allow(File).to receive(:exists?).and_return true
        allow(File).to receive(:symlink?).and_return false
      end

      it 'raises an error' do
        expect{subject}.to raise_error RuntimeError, 'source does already exist'
      end
    end
  end

  describe 'exec!' do
    let(:mv_cmd) { "mv #{source} #{target}" }

    before do
      allow(Command).to receive(:run).with(mv_cmd)
    end

    subject { instance.exec! }

    context '(when source is a file and target does not exist yet)' do
      before do
        allow(File).to receive(:exists?).with(source).and_return true
        allow(File).to receive(:exists?).with(target).and_return false
        subject
      end

      it 'moves the source to the target' do
        expect(Command).to have_received(:run).with(mv_cmd)
      end

      it 'creates a symlink to the target' do
        expect(FileUtils).to have_received(:symlink).with(source, target)
      end
    end

    context '(when source is a symlink, target does not exist)' do
      before do
        allow(File).to receive(:exists?).with(source).and_return true
        allow(File).to receive(:exists?).with(target).and_return false
        allow(File).to receive(:symlink?).and_return true
      end

      it 'raises an exception' do
        expect { subject }.to raise_error RuntimeError
      end
    end
  end
end