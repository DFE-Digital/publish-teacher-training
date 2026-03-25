# frozen_string_literal: true

require "rails_helper"

RSpec.describe Courses::Query do # rubocop:disable RSpec/SpecFilePathFormat
  subject(:results) { described_class.call(params:) }

  context "when searching by subject" do
    let(:physics_subject) { find_or_create(:secondary_subject, :physics) }
    let(:science_subject) { find_or_create(:secondary_subject, :science) }

    let(:provider) { create(:provider, provider_name: "Alpha University") }
    let(:another_provider) { create(:provider, provider_name: "Beta University") }

    let!(:physics_course) do
      create(
        :course,
        :with_full_time_sites,
        :secondary,
        name: "Physics",
        provider: another_provider,
        subjects: [physics_subject],
        master_subject_id: physics_subject.id,
      )
    end

    let!(:science_with_physics_course) do
      create(
        :course,
        :with_full_time_sites,
        :secondary,
        name: "Science with Physics",
        provider:,
        subjects: [science_subject, physics_subject],
        master_subject_id: science_subject.id,
      )
    end

    context "when ordering by course name ascending" do
      let(:params) { { subjects: [physics_subject.subject_code], order: "course_name_ascending" } }

      it "sorts courses where the searched subject is the master subject first" do
        expect(results).to match_collection(
          [physics_course, science_with_physics_course],
          attribute_names: %w[id name],
        )
      end
    end

    context "when ordering by provider name ascending" do
      let(:params) { { subjects: [physics_subject.subject_code], order: "provider_name_ascending" } }

      it "sorts courses where the searched subject is the master subject first" do
        expect(results).to match_collection(
          [physics_course, science_with_physics_course],
          attribute_names: %w[id name],
        )
      end
    end

    context "when searching by multiple subjects" do
      let(:chemistry_subject) { find_or_create(:secondary_subject, :chemistry) }

      let!(:chemistry_course) do
        create(
          :course,
          :with_full_time_sites,
          :secondary,
          name: "Chemistry",
          provider:,
          subjects: [chemistry_subject],
          master_subject_id: chemistry_subject.id,
        )
      end

      let!(:science_with_chemistry_course) do
        create(
          :course,
          :with_full_time_sites,
          :secondary,
          name: "Science with Chemistry",
          provider: another_provider,
          subjects: [science_subject, chemistry_subject],
          master_subject_id: science_subject.id,
        )
      end

      let(:params) do
        {
          subjects: [physics_subject.subject_code, chemistry_subject.subject_code],
          order: "course_name_ascending",
        }
      end

      it "prioritises courses whose master subject matches any of the searched subjects" do
        expect(results).to match_collection(
          [chemistry_course, physics_course, science_with_chemistry_course, science_with_physics_course],
          attribute_names: %w[id name],
        )
      end
    end

    context "when no subject filter is applied" do
      let(:params) { { order: "course_name_ascending" } }

      it "does not apply master subject priority ordering" do
        expect(results).to match_collection(
          [physics_course, science_with_physics_course],
          attribute_names: %w[id name],
        )
      end
    end
  end
end
