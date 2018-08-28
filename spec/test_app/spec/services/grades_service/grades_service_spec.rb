describe GradesService do
  subject { described_class }

  before do
    ENV['CANVAS_DOMAIN'] = 'localhost'
    allow(SettingsService).to receive(:get_settings).and_return('zero_out_past_due' => 'on')

    assignment = Assignment.create(due_at: 2.days.ago, published: true)
    Submission.create(assignment: assignment)
  end

  describe 'zero_out_grades!', dynamo_db: true do
    it do
      subject.zero_out_grades!
    end
  end
end
