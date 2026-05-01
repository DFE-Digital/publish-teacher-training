# frozen_string_literal: true

require "rails_helper"

describe Courses::PublishRules::SchoolPresence do
  let(:provider) { create(:provider) }
  let(:course) { create(:course, provider:) }

  def attach_legacy_site(site)
    create(:site_status, course:, site:)
  end

  def attach_new_course_school(gias_school, site_code: "A")
    create(:course_school, course:, gias_school:, site_code:)
  end

  describe ".any?" do
    context "when the flag is off" do
      before { allow(FeatureFlag).to receive(:active?).with(:course_publishing_uses_new_school_model).and_return(false) }

      it "returns true when the course has a school-type Site attached" do
        attach_legacy_site(create(:site, provider:, site_type: :school))

        expect(described_class.any?(course)).to be(true)
      end

      it "returns false when the course has no Site attached" do
        expect(described_class.any?(course)).to be(false)
      end

      it "returns false when the course has only a study-site attached" do
        attach_legacy_site(create(:site, provider:, site_type: :study_site))

        expect(described_class.any?(course)).to be(false)
      end

      it "ignores Course::School rows" do
        attach_new_course_school(create(:gias_school))

        expect(described_class.any?(course)).to be(false)
      end
    end

    context "when the flag is on" do
      before { allow(FeatureFlag).to receive(:active?).with(:course_publishing_uses_new_school_model).and_return(true) }

      it "returns true when the course has a Course::School row" do
        attach_new_course_school(create(:gias_school))

        expect(described_class.any?(course)).to be(true)
      end

      it "returns false when the course has no Course::School row" do
        expect(described_class.any?(course)).to be(false)
      end

      it "ignores legacy Sites" do
        attach_legacy_site(create(:site, provider:, site_type: :school))

        expect(described_class.any?(course)).to be(false)
      end
    end
  end
end
