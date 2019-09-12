ExternalToolsController.class_eval do
  before_action :fix_url, only: :update

  def fix_url
    params[:external_tool][:url] = nil if params[:external_tool]&.fetch(:url, nil) == "null"
  end
end