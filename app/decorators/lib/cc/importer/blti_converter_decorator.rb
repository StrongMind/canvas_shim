CC::Importer::BLTIConverter.class_eval do
  def convert_blti_links_no_dupes!(blti_resources, converter)
    convert_blti_links(blti_resources, converter).reject do |blti_link|
      Account.default.context_external_tools.find_by(
        blti_link.slice(:url, :domain)
      )
    end
  end
end