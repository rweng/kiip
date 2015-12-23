require 'spec_helper'

describe 'kiip', type: :integration do
  let(:test_dir) { Dir.mktmpdir }
  let(:cli) { Kiip::Cli.new }
  let(:tracked_path) { File.join(test_dir, 'tracked_file') }
  let(:package_name) { 'track' }
  let(:repo_path) { File.join(test_dir, 'repo') }
  let(:tracked_path_in_repo) { File.join(repo_path, package_name, Kiip::Repository::Package.encode(tracked_path)) }

  before do
    File.open(tracked_path, 'w') { |f| f.write 'some content' }
    ENV['KIIP_REPO'] = repo_path
    Kiip::Repository.get_instance.create!

    cli.track package_name, tracked_path
  end

  after do
    FileUtils.remove_entry test_dir
  end

  describe 'sync PACKAGE' do
    shared_examples 'it asks the user to replace it' do
      it 'asks the user if the file/folder should be replaced' do
        expect_any_instance_of(HighLine).to receive(:agree).and_return 'no'

        cli.sync package_name
      end

      context '(when users says yes)' do
        it 'replaces the files through a symlink' do
          expect_any_instance_of(HighLine).to receive(:agree).and_return 'true'

          cli.sync package_name

          expect(File.symlink? tracked_path).to be true
          expect(File.readlink tracked_path).to eq(tracked_path_in_repo)
        end
      end
    end

    context '(when source is already the correct symlink)' do
      it 'does nothing' do
        cli.sync package_name

        expect(File.symlink? tracked_path).to be true
        expect(File.readlink tracked_path).to eq(tracked_path_in_repo)
      end
    end

    context '(when source is a symlink but pointing somewhere else)' do
      before do
        FileUtils.rm tracked_path
        FileUtils.ln_s '/non-existant-symlink', tracked_path
      end

      include_examples 'it asks the user to replace it'
    end

    context '(when source is a file)' do
      before do
        FileUtils.rm tracked_path
        FileUtils.touch tracked_path
      end

      include_examples 'it asks the user to replace it'
    end

    context '(when source does not exist)' do
      before do
        FileUtils.rm tracked_path
      end

      it 'creates a link at source to target' do
        cli.sync package_name

        expect(File.symlink? tracked_path).to be true
        expect(File.readlink tracked_path).to eq(tracked_path_in_repo)
      end
    end
  end



  describe 'rm PACKAGE' do
    it 'replaces the source with the target' do
      cli.rm package_name

      expect(File.exists? tracked_path).to be true
      expect(File.symlink? tracked_path).to be false
    end
  end

  describe 'track PACKAGE FILE' do
    subject! { cli.track package_name, tracked_path }

    it 'replaces the source a symlink to the repo file' do
      expect(File.symlink? tracked_path).to be true
      expect(File.readlink tracked_path).to eq(tracked_path_in_repo)
    end

    it 'copies the source to the package' do
      expect(File.file? tracked_path_in_repo).to be true
      expect(File.read tracked_path_in_repo).to eq('some content')
    end
  end
end