RSpec.shared_examples 'a task' do
  it { is_expected.to respond_to(:exec!) }
end