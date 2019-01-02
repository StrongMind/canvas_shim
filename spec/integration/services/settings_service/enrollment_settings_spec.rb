require ENGINE_RAILS_ROOT + 'spec/dynamodb_helper'

describe 'Save an enrollment setting', dynamo_db: true do
  let(:enrollment) { SettingsService::Enrollment.new }

  before do
    ENV['CANVAS_DOMAIN'] = 'integration.example.com'
    ENV['AWS_SECRET_ACCESS_KEY'] = 'SecretKey'
    ENV['AWS_ACCESS_KEY_ID'] = 'SecretKeyID'
    SettingsService::Repository.use_test_client!
  end

  xit 'creates a table' do
    expect(SettingsService::Enrollment.create_table).to eq true
  end

  xit 'creates and reads items' do
    SettingsService::Enrollment.create_table
    SettingsService::Enrollment.put(id: 1, setting: 'foo', value: 'bar')
    SettingsService::EBasicLTI::BasicOutcomes::LtiResponserollment.put(id: 1, setting: 'foo2', value: 'bar2')

    expect( SettingsService::Enrollment.get(id: 1) ).to be == {
      "foo" => 'bar',
      'foo2' => 'bar2'
    }

  end
end
