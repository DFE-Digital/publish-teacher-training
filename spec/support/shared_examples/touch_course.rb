require "rails_helper"

shared_examples "Touch course" do |model_factory|
  describe "#touch_course" do
    let!(:model) { create(model_factory) }

    it "sets changed_at on the parent course to the current time" do
      Timecop.freeze do
        model.save
        expect(model.course.changed_at).to eq Time.now.utc
      end
    end

    it "leaves updated_at on the parent course unchanged" do
      timestamp = 1.hour.ago
      model.course.update updated_at: timestamp
      model.save
      expect(model.course.updated_at).to eq timestamp
    end
  end
end
