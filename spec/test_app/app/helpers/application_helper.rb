module ApplicationHelper
    def shim_content(content_for:, selector:, &block)
        content = content_for(content_for).html_safe
        content_for(:content_to_mix, &block)
        content_to_mix = content_for(:content_to_mix)
        
        content_for(content_for, flush: true) do
            position = content.index(selector) + selector.length
            content.insert(position, content_to_mix || '')
            content.html_safe
        end
    end
end
