class CourseProgress
  attr_accessor :course, :user, :read_only

  def initialize(course, user, read_only: false)
    @course = course
    @user = user
    @read_only = read_only
  end

  def module_progressions
  end

  def requirements
  end

  def requirement_count
    1
  end

  def requirements_completed
    []
  end

  def requirement_completed_count
    1
  end

  def current_requirement_url
    'http://someurl.com'
  end

  def completed_at
    Time.now
  end

  def to_json
  end

  def modules
    []
  end
end
