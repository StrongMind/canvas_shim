Api::V1::Attachment.class_eval do

    alias_method :api_attachment_preflight_alias, :api_attachment_preflight

    def api_attachment_preflight(context, request, opts = {})
        params = opts[:params] || request.params

        allowed_filetypes = SettingsService.get_settings(object: 'school', id: 1)['allowed_filetypes']
        allowed_filetypes = allowed_filetypes.split(',') if allowed_filetypes
        unless allowed_filetypes
            render :json => {:message => I18n.t('lib.api.attachments.invalid_filetype', "Filetype not supported")}, :status => 422
            return 
        end

        unless allowed_filetypes.include?(File.extname(params[:name]).delete("."))
            render :json => {:message => I18n.t('lib.api.attachments.invalid_filetype', "Filetype not supported")}, :status => 422
            return
        end

        api_attachment_preflight_alias(context, request, opts)
    end
end