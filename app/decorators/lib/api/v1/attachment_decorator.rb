Api::V1::Attachment.class_eval do

    alias_method :api_attachment_preflight_alias, :api_attachment_preflight

    def api_attachment_preflight(context, request, opts = {})
        params = opts[:params] || request.params

        unless context.instance_of?(ContentMigration)
            allowed_filetypes = SettingsService.get_settings(object: 'school', id: 1)['allowed_filetypes']
            allowed_filetypes = allowed_filetypes ? allowed_filetypes.split(',') : []

            unless allowed_filetypes.include?(File.extname(params[:name]))
                render :json => {:message => I18n.t('lib.api.attachments.invalid_filetype', "Filetype not supported")}, :status => 422
                return
            end
        end

        api_attachment_preflight_alias(context, request, opts)
    end
end