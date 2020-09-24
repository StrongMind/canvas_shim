describe CC::Importer::BLTIConverter do
  subject { described_class.new }
  let(:blti_links_empty) do
    [{:description=>"",
    :title=>"Pointful Ed",
    :url=>"https://pointfuleducation.coursearc.com/lti",
    :custom_fields=>{},
    :extensions=>[],
    :privacy_level=>"name_only",
    :not_selectable=>nil,
    :domain=>"pointfuleducation.coursearc.com",
    :consumer_key=>nil,
    :shared_secret=>nil,
    :tool_id=>nil,
    :assignment_points_possible=>nil,
    :settings=>{},
    :migration_id=>"ge938258aa328081b4c95692eb56850b4"}]
  end

  let(:blti_links_one) do
    blti_links_empty.append(
      blti_links_empty.first.merge(consumer_key: "hi", shared_secret: "there")
    )
  end

  let(:blti_resources) { nil }
  let(:converter) { nil }

  context "missing key and secret" do
    before do
      allow(subject).to receive(:convert_blti_links).and_return(blti_links_empty)
    end

    it "returns an empty array" do
      expect(subject.convert_blti_links_no_dupes(blti_resources, converter)).to be_empty
    end
  end

  context "one has a key and secret" do
    before do
      allow(subject).to receive(:convert_blti_links).and_return(blti_links_one)
    end

    it "returns an array with one item" do
      expect(subject.convert_blti_links_no_dupes(blti_resources, converter).one?).to be
    end
  end
end