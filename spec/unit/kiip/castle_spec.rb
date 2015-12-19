require 'spec_helper'

describe Kiip::Castle do
  let(:castle_path) { '/castle_path' }
  let(:instance) { described_class.new(castle_path) }
  let(:sample_task) { Kiip::Task.new(name: 'ssh', source: '~/.ssh', target: '/castle/home/ssh') }

  describe '.run' do
    it 'calls exec on the task' do
      task = double(:task)
      expect(task).to receive(:exec!)
      instance.config.tasks['ssh'] = task
      instance.run 'ssh'
    end
  end

  describe '.list' do
    it 'returns string of all tasks in the castle config to the output' do
      instance.config.tasks['ssh'] = sample_task
      expect(instance.list).to eq(['ssh: ~/.ssh -> /castle/home/ssh'])
    end
  end

  describe '.track' do
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
        expect(instance.config.tasks.keys).to eq(['ssh'])
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