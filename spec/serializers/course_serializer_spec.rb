require "rails_helper"

describe CourseSerializer do
  let(:course) { create :course, provider: provider, changed_at: Time.zone.now + 60 }
  let(:provider) { build(:provider) }
  subject { serialize(course) }

  it { should include(course_code: course.course_code) }
  it { should include(name: course.name) }
  it { should include(recruitment_cycle: course.provider.recruitment_cycle.year) }
  it { should include(created_at: course.created_at.iso8601) }
  it { should include(changed_at: course.changed_at.iso8601) }
  it { is_expected.to_not have_key(:is_send) } # Ensure V2 API is not being included.

  context "when the course is SEND" do
    let(:course) { create :course, provider: provider, is_send: true }

    it "includes a SEND subject" do
      expect(subject[:subjects]).to include(
        "subject_code" => "U3",
        "subject_name" => "Special Educational Needs",
        "type" => nil,
      )
    end
  end

  describe "#age_range" do
    context "when the course 'age_range_in_years' is '7_to_14'" do
      let(:course) { create :course, age_range_in_years: "7_to_14" }
      it { should include(age_range: "M") }
    end

    context "when the course 'level' is 'primary'" do
      let(:course) { create :course, level: "primary" }
      it { should include(age_range: "P") }
    end

    context "default age_range" do
      let(:course) { create :course, level: "secondary" }
      it { should include(age_range: "S") }
    end
  end
end
