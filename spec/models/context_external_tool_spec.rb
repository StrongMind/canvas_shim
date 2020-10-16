describe ContextExternalTool do
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

  context "Case changes" do
    before do
      allow(SettingsService).to receive(:global_settings).and_return({ 'oauth_lti_domains' => 'sTrOnGmInD.cOm' })
    end

    it 'will return true when the domains are listed in the settings service' do
      expect(context_external_tool.is_oauth_lti_domain?).to eq true
    end

    it "will also respond to tool domain case differences" do
      cased_tool = ContextExternalTool.create(domain: 'LTI.STRONGMIND.COM')
      expect(context_external_tool.is_oauth_lti_domain?).to eq true
    end
  end

  describe "#copy_account_config?" do
    before do
      Account.class_eval do
        def self.default
          last
        end
      end

      Account.create

      tool = ContextExternalTool.create(
        domain: 'accelerate.com',
        consumer_key: "Shawman No Shawing",
        shared_secret: "Aww maaaan..."
      )

      Account.default.context_external_tools << tool
    end

    it "on happy path" do
      tool = ContextExternalTool.create(
        domain: "accelerate.com",
        consumer_key: "fake",
        shared_secret: "fake",
        context: Course.create
      )

      expect(tool.reload.shared_secret).to eq("Aww maaaan...")
    end

    it "works with happy path" do
      tool = ContextExternalTool.create(
        domain: "accelerate.com",
        consumer_key: "fake",
        shared_secret: "fake",
        context: Course.create
      )

      expect(tool.reload.shared_secret).to eq("Aww maaaan...")
    end

    it "Does not work unless course tool" do
      tool = ContextExternalTool.create(
        domain: "accelerate.com",
        consumer_key: "fake",
        shared_secret: "fake",
        context: Account.create
      )

      expect(tool.reload.shared_secret).to eq("fake")
    end

    it "Does not work unless key and secret match" do
      tool = ContextExternalTool.create(
        domain: "accelerate.com",
        consumer_key: "not_fake",
        shared_secret: "fake",
        context: Course.create
      )

      expect(tool.reload.shared_secret).to eq("fake")
    end

    it "Does not work unless domain matches" do
      tool = ContextExternalTool.create(
        domain: "not-accelerate.com",
        consumer_key: "fake",
        shared_secret: "fake",
        context: Course.create
      )

      expect(tool.reload.shared_secret).to eq("fake")
    end

    after do
      Account.class_eval do
        def self.default
          new
        end
      end
    end
  end
end


