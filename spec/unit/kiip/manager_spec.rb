require 'spec_helper'

describe Kiip::Manager, type: :unit do
  let(:instance) { Kiip::Manager.new({castles: {
      me: '~/Dropbox/kiip'
  }}) }

  subject { instance }

  describe 'track' do
    context '(when castle does not yet exist)' do
      it 'creates the castle' do
      end
    end
  end
end