# Canvas includes the root by default - unlike vanilla rails.  This makes shim
# act like Canvas
ActiveRecord::Base.include_root_in_json = true

module ActiveRecord
  class Base
    def as_json(options={})
      options[:root] = options[:include_root] if options.has_key? :include_root
      super(options)
    end
  end
end
