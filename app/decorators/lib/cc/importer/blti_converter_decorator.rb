CC::Importer::BLTIConverter.class_eval do
  def convert_blti_links_no_dupes(blti_resources, converter)
    convert_blti_links(blti_resources, converter)
  end
end