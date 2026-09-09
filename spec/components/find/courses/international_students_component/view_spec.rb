# frozen_string_literal: true

require "rails_helper"

describe Find::Courses::InternationalStudentsComponent::View, type: :component do
  include Rails.application.routes.url_helpers

  def tracked_visa_types_url(utm_content)
    find_track_click_path(
      utm_content:,
      url: I18n.t("find.get_into_teaching.url_visas_for_non_uk_trainees"),
    )
  end

  # Rendered in isolation the component has no `params[:action]`, so `preview?`
  # is true and `x_provider_url` resolves to the Publish preview path.
  def provider_url_for(course)
    provider_publish_provider_recruitment_cycle_course_path(
      course.provider_code,
      course.recruitment_cycle_year,
      course.course_code,
    )
  end

  context "when the course is fee-paying and does not sponsor Student visas" do
    let(:course) { build(:course, funding_type: "fee", can_sponsor_student_visa: false) }

    before { render_inline(described_class.new(course: CourseDecorator.new(course))) }

    it "tells candidates they’ll need the right to study" do
      expect(page).to have_text("You’ll need the right to study in the UK")
    end
  end

  context "when the course is fee-paying and does sponsor Student visas" do
    let(:course) { build(:course, funding_type: "fee", can_sponsor_student_visa: true) }

    before { render_inline(described_class.new(course: CourseDecorator.new(course))) }

    it "tells candidates they’ll need the right to study" do
      expect(page).to have_text("You’ll need the right to study in the UK")
    end

    it "tells candidates visa sponsorship may be available, but they should check" do
      expect(page).to have_text("Before you apply for this course, contact the training provider to check Student visa sponsorship is available. If it is, and you get a place on this course, we’ll help you apply for your visa.")
    end

    it "links to the types of visa candidates can apply for" do
      expect(page).to have_link(
        "find out more about the types of visa you can apply for",
        href: tracked_visa_types_url("student_visa_available_types_of_visa"),
        visible: :all,
      )
    end

    it "links to the training provider" do
      expect(page).to have_link("contact the training provider", href: provider_url_for(course), visible: :all)
    end

    it "does not tell candidates the 3-year residency rule" do
      expect(page).to have_no_text("To apply for this teaching apprenticeship course, you’ll need to have lived in the UK for at least 3 years before the start of the course")
    end

    it "does not tell candidates about settled and pre-settled status" do
      expect(page).to have_no_text("EEA nationals with settled or pre-settled status under the")
    end
  end

  context "when the course is salaried and can sponsor Skilled Worker visas" do
    let(:course) { build(:course, funding: "salary", can_sponsor_skilled_worker_visa: true) }

    before { render_inline(described_class.new(course: CourseDecorator.new(course))) }

    it "tells candidates they’ll need the right to work" do
      expect(page).to have_text("You’ll need the right to work in the UK")
    end

    it "tells candidates visa sponsorship may be available, but they should check" do
      expect(page).to have_text("Before you apply for this course, contact the training provider to check Skilled Worker visa sponsorship is available. If it is, and you get a place on this course, we’ll help you apply for your visa.")
    end

    it "links to the types of visa candidates can apply for" do
      expect(page).to have_link(
        "find out more about the types of visa you can apply for",
        href: tracked_visa_types_url("skilled_worker_visa_available_types_of_visa"),
        visible: :all,
      )
    end

    it "links to the training provider" do
      expect(page).to have_link("contact the training provider", href: provider_url_for(course), visible: :all)
    end
  end

  context "when the course has a visa_type of student_visa and sponsorship_availability of :not_available" do
    let(:course) { build(:course, funding: "fee", can_sponsor_skilled_worker_visa: false) }

    before { render_inline(described_class.new(course: CourseDecorator.new(course))) }

    it "does not show the content if visa cannont be sponsored" do
      expect(page).to have_no_text("If you do not already have the right to study or work in the UK, you can")
    end

    it "does not link to the types of visa candidates can apply for" do
      expect(page).to have_no_link("find out more about the types of visa you can apply for", visible: :all)
    end
  end

  context "when the course is salaried and does not sponsor Skilled Worker visas" do
    let(:course) { build(:course, funding: "salary", can_sponsor_skilled_worker_visa: false) }

    before { render_inline(described_class.new(course: CourseDecorator.new(course))) }

    it "tells candidates they’ll need the right to work" do
      expect(page).to have_text("You’ll need the right to work in the UK")
    end

    it "links to the types of visa candidates can apply for" do
      expect(page).to have_link(
        "find out more about the types of visa you can apply for",
        href: tracked_visa_types_url("skilled_worker_visa_not_available_types_of_visa"),
        visible: :all,
      )
    end

    it "does not link to the training provider" do
      expect(page).to have_no_link("contact the training provider", visible: :all)
    end

    it "does not tell candidates the 3-year residency rule" do
      expect(page).to have_no_text("To apply for this teaching apprenticeship course, you’ll need to have lived in the UK for at least 3 years before the start of the course")
    end

    it "does not tell candidates about settled and pre-settled status" do
      expect(page).to have_no_text("EEA nationals with settled or pre-settled status under the")
    end
  end

  context "when the course is an apprenticeship" do
    let(:course) { build(:course, funding: "apprenticeship") }

    before { render_inline(described_class.new(course: CourseDecorator.new(course))) }

    it "tells candidates the 3-year residency rule" do
      expect(page).to have_text("To apply for this teaching apprenticeship course, you’ll need to have lived in the UK for at least 3 years before the start of the course")
    end

    it "tells candidates about settled and pre-settled status" do
      expect(page).to have_text("EEA nationals with settled or pre-settled status under the")
    end
  end
end
