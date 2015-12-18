$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require 'kiip'
require 'pry'

# require support files
Dir[File.dirname(__FILE__) + "/support/**/*.rb"].each {|f| require f }

RSpec.configure do |config|
  config.include FixtureHelper, :type => :unit

  config.filter_run focus: true
  config.run_all_when_everything_filtered = true

  config.fail_fast = true

  config.before(:each) do
    allow(Command).to receive(:run) { |cmd| raise "unexpected run: '#{cmd}'" }
  end
end