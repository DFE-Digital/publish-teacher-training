require "rails_helper"

RSpec.describe CourseSearchService do
  subject { described_class.call(filter: filter, sort: sort) }

  let(:filter) { nil }
  let(:sort) { nil }
  let!(:generic_course) { create(:course, :non_salary_type_based) }

  it { is_expected.to eq([generic_course]) }

  context "with filter funding set to salary" do
    let(:filter) { { funding: "salary" } }
    let!(:salaried_course) { create(:course, :salary_type_based) }

    it { is_expected.to eq([salaried_course]) }
  end

  context "with filter qualification" do
    let(:filter) { { qualification: "qts" } }
    let!(:qts_course) { create(:course, :resulting_in_qts) }
    let!(:pgde_course) { create(:course, :resulting_in_pgde) }

    it { is_expected.to eq([qts_course]) }

    context "with multiple qualification" do
      let(:filter) { { qualification: "qts,pgde" } }

      it { is_expected.to eq([qts_course, pgde_course]) }
    end
  end

  context "with filter vacancies" do
    let(:filter) { { has_vacancies: "true" } }
    let!(:course_with_vacancies) do
      create(:course) do |course|
        create(:site_status, :findable, :full_time_vacancies, course: course)
      end
    end

    it { is_expected.to eq([course_with_vacancies]) }
  end


  context "with filter study_type" do
    let(:filter) { { study_type: "full_time" } }
    let!(:full_time_course) { generic_course }
    let!(:part_time_course) { create(:course, study_mode: :part_time) }

    it { is_expected.to eq([full_time_course]) }

    context "with multiple study_types" do
      let(:filter) { { study_type: "part_time,full_time" } }

      it { is_expected.to eq([full_time_course, part_time_course]) }
    end
  end

  context "with filter subjects" do
    let(:filter) { { subjects: "01" } }
    let(:primary_with_mathematics) { create(:primary_subject, :primary_with_mathematics) }
    let(:primary_with_english) { create(:primary_subject, :primary_with_english) }
    let!(:english_course) { create(:course, subjects: [primary_with_english]) }
    let!(:mathematics_course) { create(:course, subjects: [primary_with_mathematics]) }

    it { is_expected.to eq([english_course]) }

    context "with multiple study_types" do
      let(:filter) { { subjects: "01,03" } }

      it { is_expected.to eq([english_course, mathematics_course]) }
    end
  end

  context "with filter provider_name" do
    let(:filter) { { "provider.provider_name": "University of Cumbria" } }
    let(:cumbria_provider) { create(:provider, provider_name: "University of Cumbria") }
    let!(:cumbria_course) { create(:course, provider: cumbria_provider) }

    it { is_expected.to eq([cumbria_course]) }

    context "when provider name matches multiple results" do
      let!(:accredited_course) { create(:course, accrediting_provider: cumbria_provider) }

      it { is_expected.to eq([cumbria_course, accredited_course]) }
    end
  end

  context "with filter send_courses" do
    let(:filter) { { send_courses: "true" } }
    let!(:send_course) { create(:course, is_send: true) }

    it { is_expected.to eq([send_course]) }
  end

  context "with location filter" do
    let(:filter) { { latitude: 54.9713392, longitude: -1, radius: 30 } }

    let!(:nearby_course) do
      create(:course) do |course|
        course.site_statuses << build(:site_status, :findable, site: build(:site, latitude: 54.54, longitude: -1))
      end
    end

    let!(:nearby_university_course) do
      create(:course, provider: create(:provider, :university)) do |course|
        course.site_statuses << build(:site_status, :findable, site: build(:site, latitude: 54.11, longitude: -1))
      end
    end

    let!(:far_away_course) do
      create(:course) do |course|
        course.site_statuses << build(:site_status, :findable, site: build(:site, latitude: 54.12, longitude: -1))
      end
    end

    it { is_expected.to eq([nearby_course]) }

    context "when the radius is not specified" do
      let(:filter) { { latitude: 54.9713392, longitude: -1 } }

      it { is_expected.to match_array([generic_course, far_away_course, nearby_university_course, nearby_course]) }
    end

    context "when sorting by distance" do
      let(:sort) { "distance" }
      let(:filter) { { latitude: 54.9713392, longitude: -1 } }

      it { is_expected.to eq([nearby_course, far_away_course, nearby_university_course]) }

      context "when expand_university is true" do
        let(:filter) do
          { latitude: 54.9713392, longitude: -1, expand_university: "true" }
        end

        it { is_expected.to eq([nearby_course, nearby_university_course, far_away_course]) }
      end
    end
  end

  context "with filter funding_type" do
    let(:filter) { { funding_type: "salary" } }
    let!(:salary_course) { create(:course, :with_salary) }
    let!(:apprenticeship_course) { create(:course, :with_apprenticeship) }

    it { is_expected.to eq([salary_course]) }

    context "with multiple funding_type" do
      let(:filter) { { funding_type: "salary,apprenticeship" } }

      it { is_expected.to eq([salary_course, apprenticeship_course]) }
    end
  end

  context "with filter funding_type" do
    let(:updated_at_time) { 1.day.ago }
    let(:filter) { { updated_since: updated_at_time.iso8601 } }
    let!(:recently_updated_course) { create(:course) }

    before do
      generic_course.update!(changed_at: 10.days.ago)
    end

    it { is_expected.to eq([recently_updated_course]) }
  end

  context "when sorting by course and provider name" do
    let(:filter) { nil }
    let(:warwick_provider) { create(:provider, provider_name: "University of Warwick") }
    let(:plymouth_provider) { create(:provider, provider_name: "University of Plymouth") }
    let!(:warwick_course) { create(:course, provider: warwick_provider) }
    let!(:plymouth_course) { create(:course, provider: plymouth_provider) }
    let(:sort) { "name,provider.provider_name" }

    it { is_expected.to eq([generic_course, plymouth_course, warwick_course]) }

    context "descending provider name and course name" do
      let(:sort) { "-provider.provider_name,-name" }

      it { is_expected.to eq([warwick_course, plymouth_course, generic_course]) }
    end
  end
end
