require ENGINE_RAILS_ROOT + 'spec/dynamodb_helper'

describe 'Save an enrollment setting' do
  let(:enrollment) { SettingsService::Enrollment.new }

  before do
    ENV['CANVAS_DOMAIN'] = 'integration.example.com'
    ENV['AWS_SECRET_ACCESS_KEY'] = 'SecretKey'
    ENV['AWS_ACCESS_KEY_ID'] = 'SecretKeyID'
    SettingsService::Repository.use_test_client!
  end

  it 'creates a table' do
    expect(enrollment.create_table).to eq true
  end

  it 'creates and reads items' do
    enrollment.create_table
    enrollment.put(id: 1, setting: 'foo', value: 'bar')
    enrollment.put(id: 1, setting: 'foo2', value: 'bar2')

    expect( SettingsService::Enrollment.get(id: 1) ).to be == [
      { "id" => 1, "setting" => 'foo', "value" => 'bar' },
      { "id" => 1, "setting" => 'foo2', "value" => 'bar2' }
    ]
  end
end
