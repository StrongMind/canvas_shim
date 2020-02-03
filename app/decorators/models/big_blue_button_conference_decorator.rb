BigBlueButtonConference.class_eval do
  def strongmind_recordings
    instructure_recordings.each do |rec|
      unless rec[:playback_url].end_with?("/capture/")
        rec[:playback_url] = fabricate_playback_url(rec)
      end
    end
  end

  alias_method :instructure_recordings, :recordings
  alias_method :recordings, :strongmind_recordings

  private
  def fabricate_playback_url(rec)
    split_url = rec[:playback_url].split(rec[:recording_id])
    split_url.first + rec[:recording_id] + "/capture/"
  end
end