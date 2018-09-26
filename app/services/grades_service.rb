module GradesService
  def self.zero_out_grades!(options={})
    if options[:force] == false
      return unless SettingsService.get_settings(object: :school, id: 1)['zero_out_past_due'] == 'on'
    end

    options[:log_file] = 'zero_grader_audit_' + Time.now.strftime('%Y%m%d%H%M') + '.csv'

    # Submission.where(score: nil).find_each do |submission|
    #   Commands::ZeroOutAssignmentGrades.new(submission).call!(options)
    # end

    save_audit(options)
  end

  def self.save_audit(options)
    ENV['AWS_REGION'] = 'us-west-2'
    ENV['S3_BUCKET_NAME'] = 'canvas-docker-dev'

    options[:log_file] = 'zero_grader_audit_201809252353.csv'
    s3 = Aws::S3::Resource.new(region: ENV['AWS_REGION'])
    obj = s3.bucket(ENV['S3_BUCKET_NAME']).object('zero_grader/' + options[:log_file])
    obj.upload_file('/tmp/' + options[:log_file])
  end
end
