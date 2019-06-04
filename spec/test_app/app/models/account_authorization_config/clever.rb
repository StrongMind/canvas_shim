class AccountAuthorizationConfig::Clever
    def self.login_attributes
        ['id'.freeze, 'sis_id'.freeze, 'email'.freeze, 'student_number'.freeze, 'teacher_number'.freeze].freeze
    end

    def self.recognized_federated_attributes
        login_attributes
    end

    def self.flatten_attributes(attributes, prefix=nil)
        attributes.each_pair.reduce({}) do |a, (k, v)|
            v.is_a?(Hash) ? a.merge(flatten_attributes(v, "#{prefix}#{k}.")) : a.merge("#{prefix}#{k}" => v)
        end
    end
end