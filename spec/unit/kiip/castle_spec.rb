require 'spec_helper'

describe Kiip::Castle do
  let(:castle_path) { '/castle_path' }
  let(:instance) { described_class.new(castle_path) }
  let(:sample_package) { Kiip::Package.new(name: 'ssh', source: '~/.ssh', castle: instance) }

  describe '#run' do
    it 'calls exec on the task' do
      expect(sample_package.task).to receive(:exec!)
      instance.config.packages['ssh'] = sample_package
      instance.run 'ssh'
    end
  end

  describe '#sync!' do
    it 'calls #exec! on the packages task' do
      instance.config.packages[sample_package.name] = sample_package
      expect(sample_package.task).to receive(:exec!)
      instance.sync! sample_package.name
    end
  end

  describe '#rm' do
    before do
      instance.config.packages['ssh'] = sample_package
      allow(instance.config).to receive(:rm)
      allow(instance.config).to receive(:save!)
      allow(File).to receive(:rm)
    end

    shared_examples 'removes the package' do
      it 'removes the package from the config' do
        expect(instance.config).to receive(:save!)
        subject
        expect(instance.config).to have_received(:rm).with('ssh')
      end
    end

    context '(when task does not exist)' do
      subject { instance.rm 'unknown-task' }

      it 'raises an NotFoundError' do
        expect { subject }.to raise_error Kiip::Errors::NotFoundError
      end
    end

    context '(when no options are provided)' do
      subject { instance.rm 'ssh' }

      include_examples 'removes the package'
    end

    context '(when remove_source = true)' do
      subject { instance.rm 'ssh', remove_source: true }

      include_examples 'removes the package'

      it 'removes the source' do
        subject
        expect(File).to have_received(:rm).with(sample_package.source)
      end
    end
  end

  describe '#list' do
    it 'returns string of all packages in the castle config to the output' do
      instance.config.packages['ssh'] = sample_package
      expect(instance.list).to eq(['ssh: ~/.ssh -> /castle_path/home/ssh'])
    end
  end

  describe '#track' do
    let(:track_name) { 'ssh' }
    let(:track_path) { '~/.ssh' }
    subject { instance.track track_name, track_path }

    before do
      allow(instance).to receive(:create!)
      allow(instance.config).to receive(:save!)
      allow(instance).to receive(:run)
    end

    shared_examples 'it tracks' do
      it 'adds the path to the castle config' do
        subject
        expect(instance.config.packages.keys).to eq(['ssh'])
        expect(instance.config).to have_received(:save!)
      end

      it 'executes the task' do
        subject
        expect(instance).to have_received(:run).with('ssh')
      end
    end

    context '(when castle does not exist)' do
      context '(when the user answers with "y" to create the castle)' do
        before do
          allow_any_instance_of(HighLine).to receive(:ask).and_return('y')
        end

        it 'creates the castle' do
          subject
          expect(instance).to have_received(:create!)
        end
      end

      context '(when the user answers with anything else)' do
        before do
          allow_any_instance_of(HighLine).to receive(:ask).and_return('n')
        end

        it 'aborts' do
          subject
          expect(instance.exists?).to be false
        end
      end

      context '(when castle exists)' do
        before do
          allow(instance).to receive(:exists?).and_return true
        end

        include_examples 'it tracks'
      end
    end

    context '(when castle exists)' do
      before do
        allow(instance).to receive(:exists?).and_return true
      end

      include_examples 'it tracks'
    end
  end
end