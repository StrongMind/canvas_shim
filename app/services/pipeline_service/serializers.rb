Dir[File.dirname(__FILE__) + '/serializers/*.rb'].each {|file| require_dependency file }
module PipelineService
  module Serializers
    def self.list
      names.map{|name| self.const_get(name)}
    end

    def self.names
      constants - [:BaseMethods]
    end

    def self.repositories
      (names - [:CanvasAPIEnrollment, :UnitGrades]).map { |name| name.to_s.constantize }
    end
  end
end