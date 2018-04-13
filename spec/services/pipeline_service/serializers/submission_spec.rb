module Api
  module V1
    module Submission
    end
  end
end

class Account
  def self.default
    Struct.new(:account_users).new([])
  end
end

describe PipelineService::Serializers::Submission do
  let (:user) { double('user') }
  let (:submission){ double('submission') }
  subject { described_class.new(object: submission) }

  before do
    allow(PipelineService::Account).to receive(:account_admin).and_return(user)
  end

  describe 'Stubbed methods to work with Canvas' do
    it '#params = {}' do
      expect(subject.params).to eq({})
    end

    it '#host_with_port' do
      expect(subject.request.host_with_port).to eq 'hostwithport'
    end

  end
end
