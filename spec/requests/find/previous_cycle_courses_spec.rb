# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Previous-cycle course pages on Find", service: :find, type: :request do
  def get_cycle_course(course)
    get find_course_cycle_path(
      course.provider.provider_code,
      course.course_code,
      course.recruitment_cycle_year,
    )
  end

  def published_course(provider:, name:, start_date:, course_code: "C1")
    create(
      :course,
      :published,
      :open,
      :with_gcse_equivalency,
      provider:,
      name:,
      course_code:,
      start_date:,
    )
  end

  context "when viewing an eligible 2026 cycle course before it starts", travel: find_opens(2027) + 1.day do
    let(:previous_cycle) { find_or_create(:recruitment_cycle, year: 2026) }
    let(:previous_provider) { create(:provider, recruitment_cycle: previous_cycle, provider_code: "ABC") }
    let(:current_provider) { create(:provider, provider_code: "ABC") }
    let(:previous_course) do
      published_course(
        provider: previous_provider,
        name: "History",
        start_date: Time.zone.local(2026, 10, 1),
      )
    end
    let(:current_course) do
      published_course(
        provider: current_provider,
        name: "Geography",
        start_date: Time.zone.local(2027, 9, 1),
      )
    end

    it "shows the previous-cycle course with a banner, notifying users it's from a previous cycle, and no apply action" do
      get_cycle_course(previous_course)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("History")
      expect(response.body).to include("This course is from a previous recruitment cycle")
      expect(response.body).to include("You cannot apply for this course on Find")
      expect(response.body).not_to include("Apply for this course")
    end

    it "does not show the current-cycle version of the same course code" do
      current_course
      get_cycle_course(previous_course)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("History")
      expect(response.body).not_to include("Geography")
    end

    it "leaves the current-cycle course page unchanged" do
      get find_course_path(current_course.provider.provider_code, current_course.course_code)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Geography")
      expect(response.body).not_to include("This course is from a previous recruitment cycle")
      expect(response.body).to include("Apply for this course")
    end

    it "does not serve a current-cycle course through the cycle path" do
      get find_course_cycle_path(
        current_course.provider.provider_code,
        current_course.course_code,
        current_course.recruitment_cycle_year,
      )

      expect(response).to have_http_status(:not_found)
    end
  end

  context "when the 2026 cycle course start date has passed", travel: Time.zone.local(2026, 10, 2) do
    it "is not available" do
      previous_cycle = find_or_create(:recruitment_cycle, year: 2026)
      provider = create(:provider, recruitment_cycle: previous_cycle)
      course = published_course(
        provider:,
        name: "History",
        start_date: Time.zone.local(2026, 10, 1),
      )

      get_cycle_course(course)

      expect(response).to have_http_status(:not_found)
    end
  end

  context "when the 2026 cycle course does not start after September", travel: find_opens(2027) + 1.hour do
    it "is not available" do
      previous_cycle = find_or_create(:recruitment_cycle, year: 2026)
      provider = create(:provider, recruitment_cycle: previous_cycle)
      course = published_course(
        provider:,
        name: "History",
        start_date: Time.zone.local(2026, 9, 30),
      )

      get_cycle_course(course)

      expect(response).to have_http_status(:not_found)
    end
  end

  context "when the previous cycle is 2025", travel: find_opens(2026) + 1.day do
    it "is not available" do
      previous_cycle = find_or_create(:recruitment_cycle, year: 2025)
      provider = create(:provider, recruitment_cycle: previous_cycle)
      course = published_course(
        provider:,
        name: "History",
        start_date: Time.zone.local(2025, 11, 1),
      )

      get_cycle_course(course)

      expect(response).to have_http_status(:not_found)
    end
  end
end
