describe "ContentMigration" do
  include_context "stubbed_network"

  let(:context_external_tool) { ContextExternalTool.create(domain: 'lti.strongmind.com') }

  before do
    allow(SettingsService).to receive(:global_settings).and_return({ 'oauth_lti_domains' => 'strongmind.com' })
  end

  it 'will return true when the domains are listed in the settings service' do
    expect(context_external_tool.is_oauth_lti_domain?).to eq true
  end

  let(:context_thirdparty_tool) { ContextExternalTool.create(domain: 'lti.thirdparty.com') }

  it 'will return false when the domains are listed in the settings service' do
    expect(context_thirdparty_tool.is_oauth_lti_domain?).to eq false
  end
end


