module ActiveSupport
  class HashWithIndifferentAccess
    def delete_blank
      delete_if do |k, v|
        (v.respond_to?(:empty?) ? v.empty? : !v) or v.instance_of?(HashWithIndifferentAccess || Hash) && v.delete_blank.empty?
      end
    end
  end


end

class Hash
  def delete_blank
    delete_if do |k, v|
      (v.respond_to?(:empty?) ? v.empty? : !v) or v.instance_of?(HashWithIndifferentAccess || Hash) && v.delete_blank.empty?
    end
  end
end
