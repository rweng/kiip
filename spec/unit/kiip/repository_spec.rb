require 'spec_helper'

describe Kiip::Repository do
  let(:options) { {path: '/repository/path'} }
  let(:repository) { described_class.new **options }
  let(:package_names){ %w(ssh) }
  let(:ssh_package){ double('ssh package', name: 'ssh', exists?: true, create!: nil, track: nil, decoded_content: %w(~/.ssh)) }

  before do
    allow(repository).to receive(:package_names).and_return package_names
    allow(repository).to receive(:get_package).with('ssh').and_return ssh_package
    allow(repository).to receive(:exists?).and_return true
  end

  describe '.get_instance' do
    it 'throws an error when KIIP_REPO is not set' do
      ENV.delete 'KIIP_REPO'
      expect{described_class.get_instance}.to raise_error RuntimeError
    end

    it 'expands variables' do
      ENV['TESTVAR'] = '/tmp'
      ENV['KIIP_REPO'] = '$TESTVAR/repo'
      expect(described_class.get_instance.path).to eq '/tmp/repo'
    end
  end

  describe '#sync! ssh' do
    context '(when no name is given)' do
      subject { repository.sync! }

      it 'calls sync! on all packages' do
        expect(ssh_package).to receive(:sync!)

        subject
      end
    end
  end

  describe '#track ssh ~/.ssh' do
    let(:package_path) { File.join(repository.path, 'ssh') }
    subject { repository.track 'ssh', '~/.ssh' }

    context '(when the package does not exist)' do
      before do
        allow(ssh_package).to receive(:exists?).and_return false
      end

      it 'creates the package' do
        subject
        expect(ssh_package).to have_received(:create!)
      end
    end
  end
end
