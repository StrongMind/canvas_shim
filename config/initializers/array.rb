class Array
  def cache_key
    if @cache_key
      @cache_key
    else
      value = self.collect{|element| ActiveSupport::Cache.expand_cache_key(element) }.to_param
      @cache_key = value unless self.frozen?
      value
    end
  end
end