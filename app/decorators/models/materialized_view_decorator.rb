DiscussionTopic::MaterializedView.class_eval do
  def strongmind_materialized_view_json(opts = {})
    graded_discussion = self.discussion_topic.graded_discussion?
    opts[:show_other_users_submissions] = false
    entry_ids = nil
    if graded_discussion && launch_darkly_render_discussion_entries
      student_submission_graded = self.discussion_topic.assignment.submissions.graded.where(user_id: opts[:user_id]).any?
      if student_submission_graded
        opts[:show_other_users_submissions] = true
        entry_ids = self.entry_ids_array
      else
        entries = self.discussion_topic.discussion_entries.where(user_id: opts[:user_id])
        entry_ids = entries.pluck(:id)
        ungraded_json_structure = discussion_entry_api_json(entries, discussion_topic.context, nil, nil, [])
      end
    else
      entry_ids = self.entry_ids_array
    end

    opts[:entry_ids] = entry_ids
    opts[:json_structure] = ungraded_json_structure.present? ? ungraded_json_structure.to_json : self.json_structure
    instructure_materialized_view_json(opts)
  end

  alias_method :instructure_materialized_view_json, :materialized_view_json
  alias_method :materialized_view_json, :strongmind_materialized_view_json

  def launch_darkly_render_discussion_entries
    return true if Rails.env.development? || Rails.env.test?
    Rails.configuration.launch_darkly_client.variation("prevent_rendering_of_discussion_board_responses_until_the_student_has_received_a_grade", @launch_darkly_user, false)
  end
end
