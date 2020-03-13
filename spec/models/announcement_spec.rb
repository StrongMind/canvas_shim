describe Announcement do
  include_context "stubbed_network"

  let(:pinned_announcement) { Announcement.create(pinned: true) }
  let(:unpinned_announcement) { Announcement.create(pinned: false) }

  describe "#remove_pin" do
    let(:pin_params) {["#{pinned_announcement.id}", "#{unpinned_announcement.id}"]}
    
    it "sets pinned to false" do
      pinned_announcement.remove_pin(pin_params)
      expect(pinned_announcement.pinned).to eq(false)
    end

    it "does not update if already false" do
      expect(unpinned_announcement).to_not receive(:update)
      unpinned_announcement.remove_pin(pin_params)
    end
  end

  describe "#add_pin" do
    let(:pin_params) {["#{pinned_announcement.id}", "#{unpinned_announcement.id}"]}

    it "sets pinned to true" do
      unpinned_announcement.add_pin(pin_params)
      expect(unpinned_announcement.pinned).to eq(true)
    end

    it "does not update if already true" do
      expect(pinned_announcement).to_not receive(:update)
      pinned_announcement.add_pin(pin_params)
    end
  end

  describe "#expired?" do
    context "not expired" do
      before do
        allow(SettingsService).to receive(:get_settings).and_return({"expiration_date" => "01-01-2222"})
      end

      it "returns false" do
        expect(pinned_announcement.is_expired?).to be_falsy
      end
    end

    context "no setting" do
      before do
        allow(SettingsService).to receive(:get_settings).and_return({"expiration_date" => false})
      end

      it "returns false" do
        expect(pinned_announcement.is_expired?).to be_falsy
      end
    end

    context "expired" do
      before do
        allow(SettingsService).to receive(:get_settings).and_return({"expiration_date" => "01-01-2010"})
      end

      it "returns false" do
        expect(pinned_announcement.is_expired?).to be_truthy
      end
    end
  end

  describe "::reorder_pinned_announcements" do
    let(:pinned_announcement_2) { Announcement.create(pinned: true) }
    let(:params) do 
      {pinned_announcement.id.to_s => "1", pinned_announcement_2.id.to_s => "2"}
    end
    it "sets position of announcements" do
      Announcement.reorder_pinned_announcements(params)
      expect(Announcement.find(pinned_announcement.id).position).to eq 1
    end
  end
end