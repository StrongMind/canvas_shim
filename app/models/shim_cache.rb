class ShimCache
  def self.safe_cache_key(*args)
    key = args.cache_key
    if key.length > 200
      key = Digest::MD5.hexdigest(key)
    end
    key
  end

  def cache(name = {}, options = {}, &block)
    unless options && options[:no_locale]
      name = name.cache_key if name.respond_to?(:cache_key)
      name = name + "/#{I18n.locale}" if name.is_a?(String)
    end
    super
  end
end
