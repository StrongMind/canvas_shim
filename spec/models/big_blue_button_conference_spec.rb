describe BigBlueButtonConference do
  subject { described_class }
  
  describe "#recordings" do
      context "good recording" do
        let (:good_recording) do
          {
            :recording_id=>"d7d1e678be17a7d2c32a475f09776597e09a1b04-1580489255668",
            :duration_minutes=>1,
            :playback_url=>"https://recordings.rna1.blindsidenetworks.com/strongmind/d7d1e678be17a7d2c32a475f09776597e09a1b04-1580489255668/capture/",
            :statistics_url=>"https://recordings.rna1.blindsidenetworks.com/strongmind/d7d1e678be17a7d2c32a475f09776597e09a1b04-1580489255668/statistics/"
          }
        end

        let(:bbb) { subject.create }

        before do
          allow(bbb).to receive(:instructure_recordings).and_return([good_recording])
        end

        it "does not receive #generate_recording_url" do
          expect(bbb).to receive(:generate_recording_url).once
          bbb.recordings
        end
      end

      context "bad recording" do
        let(:bad_recording) do
          {
            :recording_id=>"d7d1e678be17a7d2c32a475f09776597e09a1b04-1580489255668",
            :duration_minutes=>1,
            :playback_url=>"https://recordings.rna1.blindsidenetworks.com/strongmind/d7d1e678be17a7d2c32a475f09776597e09a1b04-1580489255668/statistics/",
            :statistics_url=>"https://recordings.rna1.blindsidenetworks.com/strongmind/d7d1e678be17a7d2c32a475f09776597e09a1b04-1580489255668/statistics/"
          }
        end

        let(:bbb) { subject.create }

        before do
          allow(bbb).to receive(:instructure_recordings).and_return([bad_recording])
        end

        it "receives #generate_recording_url" do
          expect(bbb).to receive(:generate_recording_url).twice
          bbb.recordings
        end

        it "changes the bad recording url" do
           expect(bbb.recordings.first[:playback_url]).to eq("https://recordings.rna1.blindsidenetworks.com/strongmind/d7d1e678be17a7d2c32a475f09776597e09a1b04-1580489255668/capture/")
        end
      end
  end
end