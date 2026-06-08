# frozen_string_literal: true

require "rails_helper"

RSpec.describe Publish::Courses::InformationComponent, type: :component do
  subject(:render_component) { render_inline(described_class.new(course: course.decorate)) }

  let(:course) { build_stubbed(:course, course_attributes) }
  let(:course_attributes) { {} }

  describe "funding type" do
    {
      fee: "Fee-paying",
      salary: "Salaried",
      apprenticeship: "Apprenticeship",
    }.each do |funding, label|
      context "when the course is #{funding}" do
        let(:course_attributes) { { funding: } }

        it "renders #{label.inspect}" do
          render_component

          expect(page).to have_text(label)
        end
      end
    end

    context "when the course is a teacher degree apprenticeship" do
      let(:course) { build_stubbed(:course, :with_teacher_degree_apprenticeship) }

      it "renders Apprenticeship" do
        render_component

        expect(page).to have_text("Apprenticeship")
      end
    end
  end

  describe "qualification" do
    {
      qts: "QTS",
      pgce_with_qts: "QTS with PGCE",
      undergraduate_degree_with_qts: "Teacher degree apprenticeship with QTS",
    }.each do |qualification, label|
      context "when the qualification is #{qualification}" do
        let(:course_attributes) { { qualification: } }

        it "renders #{label.inspect}" do
          render_component

          expect(page).to have_text(label)
        end
      end
    end
  end

  describe "study type" do
    {
      full_time: "Full time",
      part_time: "Part time",
      full_time_or_part_time: "Full time or part time",
    }.each do |study_mode, label|
      context "when the study mode is #{study_mode}" do
        let(:course_attributes) { { study_mode: } }

        it "renders #{label.inspect}" do
          render_component

          expect(page).to have_text(label)
        end
      end
    end
  end

  describe "start date" do
    context "when the course has a start date" do
      let(:course_attributes) { { start_date: Time.zone.local(2026, 9, 1) } }

      it "renders the month and year in govuk-!-font-size-16" do
        render_component

        expect(page).to have_css("span.govuk-\\!-font-size-16", text: "September 2026")
      end
    end

    context "when the course has no start date" do
      let(:course_attributes) { { start_date: nil } }

      it "does not render a start date line" do
        render_component

        expect(page).to have_no_css("span.govuk-\\!-font-size-16")
      end
    end
  end

  it "renders each piece of information on its own line" do
    render_component

    expect(page).to have_css("span.govuk-\\!-display-block", minimum: 4)
  end
end
