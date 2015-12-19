require 'spec_helper'

describe Kiip::Tasks::SymlinkTask, type: :unit do

  let(:source) { '~/.ssh' }
  let(:target) { '~/Drobox/kiip/home/ssh' }

  let(:instance) { described_class.new(
      name: 'def_name',
      source: source,
      target: target,
  ) }

  subject { instance }

  it_should_behave_like 'a task'

  before do
    allow(instance).to receive(:move_source_to_target)
    allow(instance).to receive(:create_symlink_from_source_to_target)
  end

  describe 'exec!' do
    subject { instance.exec! }

    context '(when target does not exist)' do
      before do
        allow(File).to receive(:exists?).with(instance.target).and_return false
      end

      context '(when source does not exist)' do
        before do
          allow(File).to receive(:exists?).with(instance.source).and_return false
        end
      end

      context '(when source is a file/folder)' do
        before do
          allow(File).to receive(:exists?).with(source).and_return true
          subject
        end

        it 'moves the source to the target' do
          expect(instance).to have_received(:move_source_to_target)
        end

        it 'creates a symlink to the target' do
          expect(instance).to have_received(:create_symlink_from_source_to_target)
        end
      end

      context '(when source is a symlink)' do
        before do
          allow(File).to receive(:exists?).with(source).and_return true
          allow(File).to receive(:symlink?).and_return true
        end

        it 'raises an exception' do
          expect { subject }.to raise_error RuntimeError
        end
      end
    end

    context '(when target exists)' do
      before do
        allow(File).to receive(:exists?).with(instance.target).and_return true
      end

      context '(when source does not exist)' do
        before do
          allow(File).to receive(:exists?).with(instance.source).and_return false
        end

        it 'recreates the symlink' do
          subject

          expect(instance).to have_received(:create_symlink_from_source_to_target)
        end
      end

      context '(when source is already the correct link)' do
        before do
          allow(File).to receive(:exists?).with(source).and_return true
          allow(File).to receive(:symlink?).with(source).and_return true
          allow(File).to receive(:readlink).with(source).and_return target
        end

        it 'does nothing' do
          subject
          expect(instance).not_to have_received(:create_symlink_from_source_to_target)
        end
      end

      context '(when source does exist, but is not a symlink)' do
        before do
          allow(File).to receive(:exists?).with(source).and_return true
          allow(File).to receive(:symlink?).with(source).and_return false
        end

        it 'raises an error' do
          expect { subject }.to raise_error RuntimeError, 'source and target cant both exist'
        end
      end
    end
  end
end