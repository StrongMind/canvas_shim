# Preload all of the serializers.  Rails does just in time loading.  This makes sure all
# the modules are loaded so when we call for the constants, ruby returns something
Dir[File.dirname(__FILE__) + '/serializers/*.rb'].each {|file| require_dependency file }
module PipelineService
  module Serializers
    # A list of all of the serializers
    def self.list
      names.map{|name| self.const_get(name)}
    end

    # A list of serializer names
    def self.names
      constants - [:BaseMethods]
    end

    # A list of the active record models that are used by the serializers
    def self.repositories
      (names - [
        :CanvasAPIEnrollment, 
        :UnitGrades, 
        :CourseProgress, 
        :ModuleItem
      ]
      ).map { |name| name.to_s.constantize }
    end
  end
end
