
module Permissions
    def self.register(name_or_hash, data={})
        @permissions ||= {}
        if name_or_hash.is_a?(Hash)
            raise ArgumentError unless data.empty?
            @permissions.merge!(name_or_hash)
        else
            raise ArgumentError if data.empty?
            @permissions.merge!(name_or_hash => data)
        end
    end

    # Return the list of registered permissions.
    def self.retrieve
        @permissions ||= {}
        @permissions.freeze unless @permissions.frozen?
        @permissions
    end
end