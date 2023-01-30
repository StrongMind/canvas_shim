class DiscussionTopic::MaterializedView < ActiveRecord::Base
  def materialized_view_json(opts = {})
    if !up_to_date?
      update_materialized_view
    end
    
    json_structure ||= opts[:json_structure]
    entry_ids ||= opts[:entry_ids]

    if json_structure.present?
      participant_ids = self.participants_array

      if opts[:include_new_entries] && opts[:show_other_users_submissions]
        @for_mobile = true if opts[:include_mobile_overrides]

        new_entries = all_entries.count != entry_ids.count ? all_entries.where.not(:id => entry_ids).to_a : []
        participant_ids = (Set.new(participant_ids) + new_entries.map(&:user_id).compact + new_entries.map(&:editor_id).compact).to_a
        entry_ids = (Set.new(entry_ids) + new_entries.map(&:id)).to_a
        new_entries_json_structure = discussion_entry_api_json(new_entries, discussion_topic.context, nil, nil, [])
      else
        new_entries_json_structure = []
      end

      return json_structure, participant_ids, entry_ids, new_entries_json_structure
    else
      return nil
    end
  end
end