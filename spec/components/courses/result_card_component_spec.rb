# frozen_string_literal: true

require "rails_helper"

RSpec.describe Courses::ResultCardComponent, type: :component do
  let(:provider) { create(:provider, provider_name: "Bishop Challoner") }
  let(:mathematics) { find_or_create(:secondary_subject, :mathematics) }

  let(:fee_course) do
    create(
      :course,
      :secondary,
      :closed,
      provider:,
      name: "Mathematics",
      course_code: "M001",
      funding: "fee",
      qualification: "pgce_with_qts",
      study_mode: "full_time",
      subjects: [mathematics],
      enrichments: [build(:course_enrichment, :published, fee_uk_eu: 9_535)],
    )
  end
  let(:salaried_course) do
    create(
      :course,
      :secondary,
      :open,
      :with_salary,
      provider:,
      name: "Mathematics",
      course_code: "M002",
      qualification: "qts",
      study_mode: "part_time",
      subjects: [mathematics],
    )
  end
  let(:courses) { [fee_course, salaried_course] }
  let(:options) { {} }

  let(:result_card) { render_inline(described_class.new(courses:, **options)) }

  def course_details(course_code)
    result_card.css(".app-search-result__course").find { |details| details.text.include?(course_code) }
  end

  def squish_html(html)
    html.to_s.gsub(/>\s+</, "><").squish
  end

  context "with one course" do
    let(:courses) { [fee_course] }

    it "looks the same as today's card" do
      today = render_inline(Courses::SummaryCardComponent.new(course: fee_course))

      expect(squish_html(result_card)).to eq(squish_html(today))
    end
  end

  context "with several courses from one provider" do
    it "shows the provider once, as the card's heading" do
      expect(result_card).to have_css("li.app-search-results__item", count: 1)
      expect(result_card).to have_css("h2", count: 1)
      expect(result_card).to have_css("h2.govuk-summary-card__title", text: "Bishop Challoner")
    end

    it "lists each course under it, in the order given" do
      links = result_card.css(".govuk-summary-card__content h3 a.app-search-result__course-name")

      expect(links.map(&:text)).to eq(["Mathematics (M001) at Bishop Challoner", "Mathematics (M002) at Bishop Challoner"])
    end

    it "puts a divider between the courses only" do
      expect(result_card).to have_css(".govuk-summary-card__content hr.govuk-section-break--visible", count: 1)
    end

    it "shows each course's own status, funding, qualification and study mode" do
      expect(course_details("M001")).to have_text("Not accepting applications")
      expect(course_details("M001")).to have_text("£9,535 fee for UK citizens")
      expect(course_details("M001")).to have_text("QTS with PGCE, full time")

      expect(course_details("M002")).not_to have_text("Not accepting applications")
      expect(course_details("M002")).to have_text("Salary")
      expect(course_details("M002")).to have_text("QTS, part time")
    end

    it "shows the school experience box only on the course that has it" do
      allow(salaried_course).to receive(:show_school_experience?).and_return(true)

      expect(course_details("M001")).not_to have_css(".app-search-result__school-experience")
      expect(course_details("M002")).to have_css(".app-search-result__school-experience")
    end

    context "when searching by location" do
      let(:options) { { location: "Birmingham" } }

      before do
        fee_course.define_singleton_method(:minimum_distance_to_search_location) { 1.2 }
        salaried_course.define_singleton_method(:minimum_distance_to_search_location) { 4.6 }
      end

      it "shows each course's own distance" do
        expect(course_details("M001")).to have_text("2 miles")
        expect(course_details("M002")).to have_text("5 miles")
      end
    end
  end

  context "when the provider's courses share an accredited provider" do
    let(:accredited_provider) { create(:provider, :accredited_provider, provider_name: "Newman University") }
    let(:options) { { accredited_provider_names: { accredited_provider.provider_code => "Newman University" } } }

    before { courses.each { |course| course.update!(accredited_provider_code: accredited_provider.provider_code) } }

    it "shows it once, in the heading" do
      expect(result_card).to have_css(".govuk-summary-card__title", text: "Accredited by Newman University")
      expect(result_card).to have_text("Accredited by Newman University", count: 1)
    end

    context "when the provider has the subject with more than one accredited provider" do
      let(:options) do
        {
          accredited_provider_names: { accredited_provider.provider_code => "Newman University" },
          accredited_provider_conflicts: Set[[provider.id, fee_course.master_subject_id]],
        }
      end

      it "shows it under each course instead" do
        expect(result_card).not_to have_css(".govuk-summary-card__title", text: "Accredited by")
        expect(course_details("M001")).to have_text("accredited by Newman University")
        expect(course_details("M002")).to have_text("accredited by Newman University")
      end
    end
  end

  # The search's accredited provider conflicts leave out self-accredited
  # courses, so a group can mix the two without being one of them.
  context "when only some of the provider's courses have an accredited provider" do
    let(:accredited_provider) { create(:provider, :accredited_provider, provider_name: "Newman University") }
    let(:options) { { accredited_provider_names: { accredited_provider.provider_code => "Newman University" } } }

    let(:courses) { [salaried_course, fee_course] }

    before { salaried_course.update!(accredited_provider_code: accredited_provider.provider_code) }

    it "shows the accredited provider only under its course" do
      expect(result_card).not_to have_css(".govuk-summary-card__title", text: "Accredited by")
      expect(course_details("M001")).not_to have_text("accredited by")
      expect(course_details("M002")).to have_text("accredited by Newman University")
    end
  end
end
