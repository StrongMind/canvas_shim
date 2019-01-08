module CanvasShim
  module Shimmer
    def make_shimmer(included_module:, overriding_module:)
      (included_module.instance_methods & overriding_module.instance_methods).each do |method|
        included_module.instance_eval{remove_method method.to_sym}
      end
    end
  end
end
