class ObserversController < ApplicationController
    def index
        js_env(context_asset_string: 'users')
    end
end