require 'spec_helper'

describe 'kiip', type: :integration do
  let(:test_dir){ Dir.mktmpdir }
  let(:cli){ Kiip::Cli.new }
  let(:tracked_path){ File.join(test_dir, 'tracked_file') }
  let(:package_name){ 'track' }
  let(:repo_path){ File.join(test_dir, 'repo') }

  before do
    File.open(tracked_path, 'w'){ |f| f.write 'some content' }
    ENV['KIIP_REPO'] = repo_path
    Kiip::Repository.get_instance.create!

    cli.track package_name, tracked_path
  end

  after do
    FileUtils.remove_entry test_dir
  end

  describe 'rm PACKAGE' do
    it 'replaces the source with the target' do
      cli.rm package_name

      expect(File.exists? tracked_path).to be true
      expect(File.symlink? tracked_path).to be false
    end
  end
end