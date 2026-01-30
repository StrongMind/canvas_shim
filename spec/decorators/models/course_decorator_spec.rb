require 'spec_helper'

describe "Course.process_course_touch" do
  describe ".process_course_touch" do
    context "when course exists" do
      it "touches the course and returns true" do
        course = double("course")
        allow(Course).to receive(:find_by_id).with("123").and_return(course)
        expect(course).to receive(:touch)

        result = Course.process_course_touch("123")
        expect(result).to be true
      end
    end

    context "when course does not exist" do
      it "logs a warning and returns false" do
        allow(Course).to receive(:find_by_id).with("999").and_return(nil)
        expect(Rails.logger).to receive(:warn).with("[touch_courses] Course 999 not found, removing stale reference")

        result = Course.process_course_touch("999")
        expect(result).to be false
      end
    end
  end
end
