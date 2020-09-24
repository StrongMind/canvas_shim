CC::Importer::BLTIConverter.class_eval do
  def convert_blti_links_no_dupes(blti_resources, converter)
    convert_blti_links(blti_resources, converter).reject do |blti_link|
      blti_link.values_at(:shared_key, :shared_secret).none?
    end
  end
end