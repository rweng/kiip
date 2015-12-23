require 'spec_helper'

describe Kiip::Repository do
  let(:options) { {path: '/repository/path', dry: false} }
  let(:repository) { described_class.new **options }
  let(:package_names){ %w(ssh) }
  let(:ssh_package){ double('ssh package', name: 'ssh', exists?: true, create!: nil, track: nil, content: %w(~:.ssh)) }

  before do
    allow(repository).to receive(:package_names).and_return package_names
    allow(repository).to receive(:get_package).with('ssh').and_return ssh_package
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

  describe '#exists?' do
    let(:id_file_exists_return_value) { false }

    before do
      allow(File).to receive(:exists?).with(File.join(repository.path, Kiip::Repository::ID_FILE_NAME)).and_return id_file_exists_return_value
    end

    subject { repository.exists? }

    context "(when #{Kiip::Repository::ID_FILE_NAME} exists in the repository folder)" do
      let(:id_file_exists_return_value) { true }

      it { is_expected.to be true }
    end

    context "(when #{Kiip::Repository::ID_FILE_NAME} does not exist exists in the repository folder)" do
      let(:id_file_exists_return_value) { false }

      it { is_expected.to be false }
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

  describe '#print_content' do
    subject { repository.print_content }

    context 'when a package with name "ssh" exists with content "~/.ssh"' do
      before do
        allow(ssh_package).to receive(:entries).with(File.join(repository.path, 'ssh')).and_return %w(. .. ~/.ssh)
        allow(Dir).to receive(:entries).with(File.join(repository.path, 'ssh')).and_return %w(. .. ~/.ssh)
      end

      it do
        is_expected.to eq <<-END
ssh:
  ~/.ssh
        END
      end
    end
  end
end
