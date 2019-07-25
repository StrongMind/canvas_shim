LtiOutboundAdapter.class_eval do

    def launch_url
        raise('Called launch_url before calling prepare_tool_launch') unless @tool_launch
        post_only && !disable_post_only? ? @tool_launch.url.split('?').first : @tool_launch.url
    end
end
