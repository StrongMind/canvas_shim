class Feature
  def initialize(attrs)
    
  end

  def self.definitions
    @features
  end
  
  def self.register(feature_hash)
    @features ||= {}
    feature_hash.each do |feature_name, attrs|
      feature = feature_name.to_s
      @features[feature] = Feature.new({feature: feature}.merge(attrs))
    end
  end
end