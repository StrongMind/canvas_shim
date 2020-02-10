BigBlueButtonConference.class_eval do
  def strongmind_recordings
    instructure_recordings.each do |rec|
      unless rec[:playback_url].end_with?("/capture/")
        rec[:playback_url] = generate_recording_url(rec, "/capture/")
      end
      rec[:statistics_url] = generate_recording_url(rec, "/statistics/")
    end
  end

  alias_method :instructure_recordings, :recordings
  alias_method :recordings, :strongmind_recordings

  private
  def generate_recording_url(rec, path)
    rec[:playback_url].split(rec[:recording_id]).first + rec[:recording_id] + path
  end
end