describe AssignmentsService::Commands::DistributeDueDates do
  let(:account_instance) {
    double(
      'default_account',
      feature_enabled?: true,
      account_users:        [
        Struct.new(:role, :user).new(
          Struct.new(:name).new('AccountAdmin'),
            'account admin user'
          )
      ]
    )
  }

  before do
    allow(SettingsService).to receive(:update_settings).and_return({})
    allow(SettingsService).to receive(:get_settings).and_return('auto_due_dates' => 'on')
    allow(Account).to receive(:default).and_return(account_instance)
  end

  let(:start_at) { Date.parse("Mon Nov 26 2018") }
  let(:end_at)   { start_at + 7.days }

  let(:content_migrations) do
    double(
      :content_migrations,
      where: [1, 2]
    )
  end

  let(:course) do
    double(
      :course,
      start_at: start_at,
      end_at: end_at,
      id: 1,
      time_zone: Time.zone,
      content_migrations: content_migrations
    )
  end

  let(:ordered_content_tags) do
    [
      double(:content_tag, content_type: nil, assignment: assignment),
      double(:content_tag, content_type: nil, assignment: assignment2),
      double(:content_tag, content_type: nil, assignment: assignment3),
      double(:content_tag, content_type: nil, assignment: assignment4),
      double(:content_tag, content_type: nil, assignment: assignment5),
      double(:content_tag, content_type: nil, assignment: assignment6),
      double(:content_tag, content_type: nil, assignment: assignment7),
      double(:content_tag, content_type: nil, assignment: assignment8),
      double(:content_tag, content_type: nil, assignment: assignment9),
      double(:content_tag, content_type: nil, assignment: assignment10)
    ]
  end

  let(:ordered_context_modules) do
    [
      double(:context_module, content_tags: double(:context_module, where: content_tags))
    ]
  end

  let(:content_tags) { double(:content_tags, order: ordered_content_tags) }
  let(:assignment)  { double(:assignment, update: nil) }
  let(:assignment2) { double(:assignment2, update: nil) }
  let(:assignment3) { double(:assignment3, update: nil) }
  let(:assignment4)  { double(:assignment4, update: nil) }
  let(:assignment5) { double(:assignment5, update: nil) }
  let(:assignment6) { double(:assignment6, update: nil) }
  let(:assignment7) { double(:assignment7, update: nil) }
  let(:assignment8) { double(:assignment8, update: nil) }
  let(:assignment9) { double(:assignment9, update: nil) }
  let(:assignment10) { double(:assignment10, update: nil) }
  let(:context_modules) { double(:context_modules, order: ordered_context_modules) }

  subject { described_class.new(course: course) }

  before do
    allow(ContentTag).to receive(:where).and_return(content_tags)
    allow(ContextModule).to receive(:where).and_return(context_modules)
  end

  describe "#call" do
    context 'auto_due_dates feature not enabled' do
      before do
        allow(SettingsService).to receive(:get_settings).and_return('auto_due_dates' => 'off')
      end

      it 'will not distribute the due dates' do
        expect(assignment).not_to(receive(:update))
        subject.call
      end
    end

    context 'course without start date' do
      let(:course) do
        double(
          :course,
          start_at: nil,
          end_at: start_at + 5.days,
          id: 1,
          content_migrations: content_migrations
        )
      end

      it 'wont distribute the due dates' do
        expect(assignment).not_to(receive(:update))
        subject.call
      end
    end

    context 'course without end date' do
      let(:course) do
        double(
          :course,
          start_at: start_at,
          end_at: nil,
          id: 1,
          content_migrations: content_migrations
        )
      end

      it 'wont distribute the due dates' do
        expect(assignment).not_to(receive(:update))
        subject.call
      end
    end

    it 'distributes the assignments across workdays' do
      expect(assignment).to(
        receive(:update).with(due_at: Time.parse('2018-11-27 23:59:59.999999999 +0000'))
      )

      expect(assignment2).to(
        receive(:update).with(due_at: Time.parse('2018-11-27 23:59:59.999999999 +0000'))
      )

      expect(assignment3).to(
        receive(:update).with(due_at: Time.parse('2018-11-27 23:59:59.999999999 +0000'))
      )

      expect(assignment4).to(
        receive(:update).with(due_at: Time.parse('2018-11-28 23:59:59.999999999 +0000'))
      )
      subject.call
    end

    context 'Process a discussion topic without an assignment' do
      let(:assignment) { double('assignment', nil?: true) }
      let(:content_tags) { double(:content_tags, order: [double('DisscussionTopic', assignment: assignment, content_type: nil)]) }

      it 'wont break' do
        expect(assignment).not_to(receive(:update))
        subject.call
      end
    end

    context 'Has less assignments than days' do
      let(:course) do
        double(
          :course,
          start_at: start_at,
          end_at: end_at + 1.year,
          id: 1,
          time_zone: Time.zone,
          content_migrations: content_migrations
        )
      end

      it 'assigns the last assignment on the last day' do
        expect(assignment10).to(receive(:update)).once.with(due_at: Time.parse('2019-11-29 23:59:59.999999999 +0000'))
        subject.call
        dates = subject.instance_variable_get(:@scheduler).course_dates
        expect(dates.values.last).to eq 1
      end
    end
  end
end
