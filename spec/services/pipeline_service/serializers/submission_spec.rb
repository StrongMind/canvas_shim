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
    it '#retrieve_course_external_tools_url = nil' do
      expect(subject.retrieve_course_external_tools_url).to eq nil
    end

    it '#course_assignment_submission_url = \'\'' do
      expect(subject.course_assignment_submission_url(1,2,3,4)).to eq ''
    end

    it '#params = {}' do
      expect(subject.params).to eq({})
    end

    it '#polymorphic_url = \'\'' do
      expect(subject.polymorphic_url(['1', :file_download], file_id: '2')).to eq ''
    end
  end
end
