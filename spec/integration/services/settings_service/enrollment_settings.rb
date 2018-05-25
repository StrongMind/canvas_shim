describe 'Save an enrollment setting' do
  let(:enrollment) { SettingsService::Enrollment.new }

  before do
    ENV['CANVAS_DOMAIN'] = 'integration.example.com'
    ENV['AWS_SECRET_ACCESS_KEY'] = 'SecretKey'
    ENV['AWS_ACCESS_KEY_ID'] = 'SecretKeyID'
  end

  it 'works' do
    expect(enrollment.create_table).to eq(true)
  end
end
