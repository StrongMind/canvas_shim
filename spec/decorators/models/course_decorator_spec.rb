require 'rails_helper'

# Stub Redis classes if not already defined (redis gem may not be loaded in test env)
unless defined?(Redis)
  class Redis
    class BaseError < StandardError; end
    class CannotConnectError < BaseError; end
  end
end

describe "CourseDecorator" do
  describe ".touch_courses" do
    let(:redis) { instance_double("Redis") }
    let(:course) { double("course", id: 123) }

    before do
      allow(Redis).to receive(:new).and_return(redis)
      allow(ENV).to receive(:[]).with('REDIS_SERVER').and_return('redis://localhost:6379')
    end

    context "when redis returns course IDs" do
      before do
        allow(redis).to receive(:smembers).with("courses_to_touch").and_return(["123", "456"])
        allow(redis).to receive(:srem)
      end

      it "touches existing courses and removes them from redis" do
        course1 = double("course1")
        course2 = double("course2")

        allow(Course).to receive(:find_by_id).with("123").and_return(course1)
        allow(Course).to receive(:find_by_id).with("456").and_return(course2)

        expect(course1).to receive(:touch)
        expect(course2).to receive(:touch)
        expect(redis).to receive(:srem).with("courses_to_touch", "123")
        expect(redis).to receive(:srem).with("courses_to_touch", "456")

        Course.touch_courses
      end
    end

    context "when redis.smembers returns nil" do
      before do
        allow(redis).to receive(:smembers).with("courses_to_touch").and_return(nil)
      end

      it "does not raise an error" do
        expect { Course.touch_courses }.not_to raise_error
      end

      it "does not attempt to touch any courses" do
        expect(Course).not_to receive(:find_by_id)
        Course.touch_courses
      end
    end

    context "when redis.smembers returns an empty array" do
      before do
        allow(redis).to receive(:smembers).with("courses_to_touch").and_return([])
      end

      it "does not raise an error" do
        expect { Course.touch_courses }.not_to raise_error
      end

      it "does not attempt to touch any courses" do
        expect(Course).not_to receive(:find_by_id)
        Course.touch_courses
      end
    end

    context "when a course does not exist" do
      before do
        allow(redis).to receive(:smembers).with("courses_to_touch").and_return(["123", "999"])
        allow(redis).to receive(:srem)
        allow(Course).to receive(:find_by_id).with("123").and_return(course)
        allow(Course).to receive(:find_by_id).with("999").and_return(nil)
        allow(course).to receive(:touch)
      end

      it "logs a warning for the missing course" do
        expect(Rails.logger).to receive(:warn).with("[touch_courses] Course 999 not found, removing stale reference")
        Course.touch_courses
      end

      it "still removes the stale reference from redis" do
        allow(Rails.logger).to receive(:warn)
        expect(redis).to receive(:srem).with("courses_to_touch", "123")
        expect(redis).to receive(:srem).with("courses_to_touch", "999")
        Course.touch_courses
      end

      it "touches existing courses" do
        allow(Rails.logger).to receive(:warn)
        expect(course).to receive(:touch)
        Course.touch_courses
      end
    end

    context "when redis raises an error" do
      before do
        allow(redis).to receive(:smembers).and_raise(Redis::CannotConnectError.new("Connection refused"))
      end

      it "does not raise an error" do
        allow(Rails.logger).to receive(:error)
        expect { Course.touch_courses }.not_to raise_error
      end

      it "logs the error" do
        expect(Rails.logger).to receive(:error).with("[touch_courses] Redis error: Connection refused")
        Course.touch_courses
      end

      it "captures the exception in Sentry if defined" do
        allow(Rails.logger).to receive(:error)

        sentry_module = Module.new do
          def self.capture_exception(exception); end
        end
        stub_const("Sentry", sentry_module)

        expect(Sentry).to receive(:capture_exception).with(an_instance_of(Redis::CannotConnectError))
        Course.touch_courses
      end
    end
  end
end
