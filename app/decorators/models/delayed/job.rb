Delayed::Job.class_eval do
  before_save :truncate_source_column

  def truncate_source_column
    limit = Delayed::Job.columns_hash['source'].limit
    puts self.source if self.source.length > limit
    self.source = self.source[0..limit-1] if self.source.length > limit
  end
end
