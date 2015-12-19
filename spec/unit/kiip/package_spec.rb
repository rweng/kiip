require 'spec_helper'

describe Kiip::Package, type: :unit do
  let(:package) { described_class.new name: 'ssh', source: '~/.ssh' }

  describe '#task' do
    context '(when castle not set)' do
      before do
        package.castle = nil
      end

      it 'throws an IllegalStateError' do
        expect{package.task}.to raise_error Kiip::Errors::IllegalStateError
      end
    end

    context '(when castle is set)' do
      before do
        package.castle = double(:castle)
      end

      it 'returns a SymlinkTask' do
        allow(package.castle).to receive(:package_path).and_return '/tmp/some-package-path'

        expect(package.task).to be_an_instance_of Kiip::Tasks::SymlinkTask
      end
    end
  end
end