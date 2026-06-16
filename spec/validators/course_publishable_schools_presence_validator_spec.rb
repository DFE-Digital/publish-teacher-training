# frozen_string_literal: true

require "rails_helper"

describe CoursePublishableSchoolsPresenceValidator do
  let(:course) { build_stubbed(:course) }

  def run_validator
    course.errors.clear
    described_class.new.validate(course)
  end

  it "does not add an error when SchoolPresence reports schools attached" do
    allow(Courses::PublishRules::SchoolPresence).to receive(:any?).with(course).and_return(true)

    run_validator

    expect(course.errors[:sites]).to be_empty
  end

  it "adds a :blank error on :sites when SchoolPresence reports no schools" do
    allow(Courses::PublishRules::SchoolPresence).to receive(:any?).with(course).and_return(false)
    allow(Courses::PublishRules::SchoolPresenceExemption).to receive(:applies?).with(course).and_return(false)

    run_validator

    expect(course.errors.details[:sites]).to include(error: :blank)
  end

  it "does not add an error when no schools are attached but the exemption applies" do
    allow(Courses::PublishRules::SchoolPresence).to receive(:any?).with(course).and_return(false)
    allow(Courses::PublishRules::SchoolPresenceExemption).to receive(:applies?).with(course).and_return(true)

    run_validator

    expect(course.errors[:sites]).to be_empty
  end

  # Integration of the validator with the real SchoolPresence and
  # SchoolPresenceExemption rules and real Course::School records, covering the
  # ticket's publish matrix under the new school model.
  describe "validation matrix (new school model)" do
    let(:provider) { create(:provider) }
    let(:course) { create(:course, funding, provider:, publish_without_schools_allowed: exemption) }

    def attach_school
      create(:course_school, course:, gias_school: create(:gias_school))
    end

    before { allow(FeatureFlag).to receive(:active?).with(:course_publishing_uses_new_school_model).and_return(true) }

    {
      [:salary,         true,  true]  => :no_error,
      [:salary,         true,  false] => :no_error,
      [:salary,         false, true]  => :no_error,
      [:salary,         false, false] => :blank,
      [:apprenticeship, false, true]  => :no_error,
      [:apprenticeship, false, false] => :blank,
      [:fee,            false, true]  => :blank,
      [:fee,            true,  true]  => :no_error,
      [:fee,            false, false] => :blank,
    }.each do |(funding, has_school, exemption), expected|
      context "#{funding}, #{has_school ? 'with' : 'without'} schools, exemption #{exemption ? 'on' : 'off'}" do
        let(:funding) { funding }
        let(:exemption) { exemption }

        it "expects #{expected == :no_error ? 'no :sites error' : "a :sites #{expected} error"}" do
          attach_school if has_school
          course.errors.clear
          described_class.new.validate(course)

          if expected == :no_error
            expect(course.errors[:sites]).to be_empty
          else
            expect(course.errors.details[:sites]).to include(error: expected)
          end
        end
      end
    end
  end
end
