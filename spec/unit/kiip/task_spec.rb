require 'spec_helper'

describe Kiip::Task, type: :unit do

  let(:source){ '/tmp/kiip-tests/source' }
  let(:target){ '/tmp/kiip-tests/target' }
  subject { described_class.new(
      name: 'def_name',
      source: source,
      target: target,
  ) }

  before do
    `rm -rf /tmp/kiip-tests`
    `mkdir -p #{source}`
    `touch #{source}/testfile`
  end

  describe 'exec!' do
    context 'when method: symlink and source does not exist' do
      it 'creates a symlink at the target' do
        expect(Command).to receive(:run).with("mv /tmp/kiip-tests/source /tmp/kiip-tests/target").and_call_original
        expect(Command).to receive(:run).with("ln -s /tmp/kiip-tests/target /tmp/kiip-tests/source").and_call_original

        subject.exec!

        expect(File.symlink?(source)).to be true
        expect(File.exists?("#{target}/testfile")).to be true
      end
    end
  end
end