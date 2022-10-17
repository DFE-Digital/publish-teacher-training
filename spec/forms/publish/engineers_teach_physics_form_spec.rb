require "rails_helper"

module Publish
  describe EngineersTeachPhysicsForm do
    let(:params) { { campaign_name: "" } }
    let(:subject_ids) { [biology_secondary_subject.id] }
    let(:course) { create(:course, :secondary, subjects: [physics_secondary_subject]) }
    let(:physics_secondary_subject) { find_or_create(:secondary_subject, :physics) }

    subject { described_class.new(course, params:) }

    describe "validation" do
      it "is not valid when campaign_name is not included" do
        form = described_class.new(course, params:)
        expect(form.valid?).to be(false)
        expect(form.errors[:campaign_name])
            .to include("Select an option")
      end

      it "is valid when campaign_names are included" do
        Course.campaign_names.keys.each do |campaign|
          form = described_class.new(course, params: { campaign_name: campaign })
          expect(form.valid?).to be(true)
        end
      end
    end
  end
end
