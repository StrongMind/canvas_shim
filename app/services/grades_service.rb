require 'fileutils'

module GradesService
  def self.zero_out_grades!(options={})
    return unless SettingsService.get_settings(object: :school, id: 1)['zero_out_past_due'] == 'on'

    options[:log_file] = 'zero_grader_audit_' + Time.now.strftime('%Y%m%d%H%M') + '.csv'
    FileUtils.touch('/tmp/' + options[:log_file])

    submissions.find_each do |submission|
      Commands::ZeroOutAssignmentGrades.new(submission).call!(options)
    end
    save_audit(options)
  end

  def self.submissions
    Submission
      .joins(assignment: :course)
      .where('submissions.workflow_state = ?', 'unsubmitted')
      .where(score: nil)
      .where(grade: nil)
      .where('cached_due_date < ?', 1.hour.ago)
      .where('courses.conclude_at > ?', Time.now)
      .where('assignments.workflow_state = ?', 'published')
  end

  def self.save_audit(options)
    return if options[:dry_run]
    s3 = Aws::S3::Resource.new(region: ENV['AWS_REGION'], access_key_id: ENV['S3_ACCESS_KEY_ID'], secret_access_key: ENV['S3_ACCESS_KEY'])
    obj = s3.bucket(ENV['S3_BUCKET_NAME']).object('zero_grader/' + options[:log_file])
    obj.upload_file('/tmp/' + options[:log_file])
  end
end
