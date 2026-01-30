require 'rails_helper'

describe Course do
  describe ".touch_courses" do
    let(:redis_instance) { double("Redis") }

    before do
      allow(Redis).to receive(:new).and_return(redis_instance)
      allow(ENV).to receive(:[]).and_call_original
      allow(ENV).to receive(:[]).with('REDIS_SERVER').and_return('redis://localhost:6379')
    end

    context "when redis.smembers returns nil" do
      before do
        allow(redis_instance).to receive(:smembers).and_return(nil)
      end

      it "does not raise an error" do
        expect { Course.touch_courses }.not_to raise_error
      end
    end

    context "when redis.smembers returns an empty array" do
      before do
        allow(redis_instance).to receive(:smembers).and_return([])
      end

      it "does not raise an error" do
        expect { Course.touch_courses }.not_to raise_error
      end
    end

    context "when a course exists" do
      let(:course) { create(:course) }

      before do
        allow(redis_instance).to receive(:smembers).and_return([course.id.to_s])
        allow(redis_instance).to receive(:srem)
      end

      it "touches the course" do
        original_updated_at = course.updated_at
        sleep(0.01) # Ensure time passes
        Course.touch_courses
        expect(course.reload.updated_at).to be > original_updated_at
      end

      it "removes the course from redis" do
        expect(redis_instance).to receive(:srem).with("courses_to_touch", course.id.to_s)
        Course.touch_courses
      end
    end

    context "when a course does not exist" do
      before do
        allow(redis_instance).to receive(:smembers).and_return(["999999"])
        allow(redis_instance).to receive(:srem)
      end

      it "logs a warning" do
        expect(Rails.logger).to receive(:warn).with("[touch_courses] Course 999999 not found, removing stale reference")
        Course.touch_courses
      end

      it "still removes the stale reference from redis" do
        allow(Rails.logger).to receive(:warn)
        expect(redis_instance).to receive(:srem).with("courses_to_touch", "999999")
        Course.touch_courses
      end
    end
  end
end
