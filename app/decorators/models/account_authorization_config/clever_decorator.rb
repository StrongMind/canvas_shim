AccountAuthorizationConfig::Clever.class_eval do
    class << self
        alias_method :login_attributes_alias, :login_attributes
    end

    def self.recognized_federated_attributes
        login_attributes_alias + [
            'name.full'.freeze,
            'name.first'.freeze,
            'name.last'.freeze,
        ]
    end

    def provider_attributes(token)
        data = flatten_attributes(me(token))
        data['name.full'] = "#{data['name.first']} #{data['name.last']}"
        data
    end
    
    def flatten_attributes(attributes, prefix=nil)
        attributes.each_pair.reduce({}) do |a, (k, v)|
            v.is_a?(Hash) ? a.merge(flatten_attributes(v, "#{prefix}#{k}.")) : a.merge("#{prefix}#{k}" => v)
        end
    end
end