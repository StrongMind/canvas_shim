CC::Importer::BLTIConverter.class_eval do
  def convert_blti_links_no_dupes(blti_resources, converter)
    convert_blti_links(blti_resources, converter).map do |blti_link|
      if blti_link.values_at(:shared_key, :shared_secret).none?
        account_tool = Account.default.context_external_tools.find_by(domain: blti_link.domain)
        if account_tool
          blti_link.merge!(shared_key: account_tool.shared_key, shared_secret: account_tool.shared_secret)
        else
          nil
        end
      else
        blti_tool
      end
    end.compact
  end
end