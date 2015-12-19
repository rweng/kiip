require 'spec_helper'

describe Kiip::Tasks::SymlinkTask, type: :unit do

  let(:source){ '~/.ssh' }
  let(:target){ '~/Drobox/kiip/home/ssh' }

  let(:instance) { described_class.new(
      name: 'def_name',
      source: source,
      target: target,
  ) }


  describe 'exec!' do
    let(:mv_cmd){"mv #{source} #{target}" }
    let(:symlink_cmd){ "ln -s #{target} #{source}" }

    before do
      allow(Command).to receive(:run).with(mv_cmd)
      allow(Command).to receive(:run).with(symlink_cmd)
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
        expect(Command).to have_received(:run).with(symlink_cmd)
      end
    end

    context '(when source is a symlink, target does not exist)' do
      before do
        allow(File).to receive(:exists?).with(source).and_return true
        allow(File).to receive(:exists?).with(target).and_return false
        allow(File).to receive(:symlink?).and_return true
      end

      it 'raises an exception' do
        expect{subject}.to raise_error RuntimeError
      end
    end
  end
end