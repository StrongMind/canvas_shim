describe Announcement do
  include_context "stubbed_network"

  describe "#toggle_pin" do
    let(:pinned_announcement) { Announcement.create(pinned: true) }
    let(:unpinned_announcement) { Announcement.create(pinned: false) }

    context "no pins" do
      let(:pin_params) {[]}
      
      it "sets pinned to false" do
        pinned_announcement.toggle_pin(pin_params)
        expect(pinned_announcement.pinned).to eq(false)
      end

      it "does not update if already false" do
        expect(unpinned_announcement).to_not receive(:update)
        unpinned_announcement.toggle_pin(pin_params)
      end
    end

    context "has pins" do
      let(:pin_params) {["#{pinned_announcement.id}", "#{unpinned_announcement.id}"]}

      it "sets pinned to true" do
        unpinned_announcement.toggle_pin(pin_params)
        expect(unpinned_announcement.pinned).to eq(true)
      end

      it "does not update if already true" do
        expect(pinned_announcement).to_not receive(:update)
        pinned_announcement.toggle_pin(pin_params)
      end
    end
  end
end