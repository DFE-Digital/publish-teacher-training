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

    # The stylesheet draws the divider between courses, so no rule is needed.
    it "wraps each course so the stylesheet can divide them" do
      expect(result_card).to have_css(".govuk-summary-card__content > .app-search-result__course", count: 2)
      expect(result_card).to have_no_css("hr")
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

    context "when not searching by provider" do
      let(:options) { { accredited_provider_names: { accredited_provider.provider_code => "Newman University" }, provider_search: false } }

      it "still shows the accredited provider under its course" do
        expect(course_details("M001")).not_to have_text("accredited by")
        expect(course_details("M002")).to have_text("accredited by Newman University")
      end
    end
  end

  context "when not searching by provider" do
    let(:newman) { create(:provider, :accredited_provider, provider_name: "Newman University") }
    let(:birmingham) { create(:provider, :accredited_provider, provider_name: "Birmingham City University") }
    let(:names) { { newman.provider_code => "Newman University", birmingham.provider_code => "Birmingham City University" } }
    let(:options) { { accredited_provider_names: names, provider_search: false } }

    context "when the courses share an accredited provider" do
      before { courses.each { |course| course.update!(accredited_provider_code: newman.provider_code) } }

      it "doesn't show it" do
        expect(result_card).not_to have_text(/accredited by/i)
      end
    end

    context "with one course" do
      let(:courses) { [fee_course] }

      before { fee_course.update!(accredited_provider_code: newman.provider_code) }

      it "doesn't show its accredited provider" do
        expect(result_card).not_to have_text(/accredited by/i)
      end
    end

    context "when the courses have different accredited providers" do
      before do
        fee_course.update!(accredited_provider_code: newman.provider_code)
        salaried_course.update!(accredited_provider_code: birmingham.provider_code)
      end

      it "shows each course's under its name" do
        expect(result_card).not_to have_css(".govuk-summary-card__title", text: "Accredited by")
        expect(course_details("M001")).to have_text("accredited by Newman University")
        expect(course_details("M002")).to have_text("accredited by Birmingham City University")
      end
    end
  end

  describe "the age range" do
    def age_range_text(course_code)
      course_details(course_code)&.at_css("p.govuk-hint")&.text&.squish
    end

    context "with grouped results" do
      before { FeatureFlag.activate(:group_search_results) }

      context "when a secondary course is on its own card" do
        let(:courses) { [fee_course] }

        it "is hidden" do
          expect(result_card).to have_no_text("Ages")
        end
      end

      context "when every secondary course on the card has the same age range" do
        before { courses.each { |course| course.update!(age_range_in_years: "11_to_16") } }

        it "is hidden on every course" do
          expect(result_card).to have_no_text("Ages")
        end
      end

      context "when the secondary courses on the card have different age ranges" do
        before do
          fee_course.update!(age_range_in_years: "11_to_16")
          salaried_course.update!(age_range_in_years: "11_to_18")
        end

        it "shows each course's own age range" do
          expect(age_range_text("M001")).to eq("Ages 11 to 16")
          expect(age_range_text("M002")).to eq("Ages 11 to 18")
        end
      end

      # Design's 7 October mock-up shows the age range on every course once
      # any of them differs, not only on the one that's different.
      context "when only one course on the card has a different age range" do
        let(:courses) do
          [fee_course, salaried_course] + %w[M003 M004 M005].map do |course_code|
            create(:course, :secondary, provider:, name: "Mathematics", course_code:, subjects: [mathematics])
          end
        end

        before { fee_course.update!(age_range_in_years: "14_to_19") }

        it "shows the age range on every course" do
          expect(age_range_text("M001")).to eq("Ages 14 to 19")
          %w[M002 M003 M004 M005].each { |course_code| expect(age_range_text(course_code)).to eq("Ages 11 to 18") }
        end
      end

      context "with primary courses" do
        let(:primary) { find_or_create(:primary_subject, :primary) }
        let(:courses) do
          %w[P001 P002].map do |course_code|
            create(:course, :primary, provider:, name: "Primary", course_code:, age_range_in_years: "5_to_11", subjects: [primary])
          end
        end

        it "shows it on every course, even when they share it" do
          expect(age_range_text("P001")).to eq("Ages 5 to 11")
          expect(age_range_text("P002")).to eq("Ages 5 to 11")
        end

        context "when a primary course is on its own card" do
          let(:courses) { [create(:course, :primary, provider:, age_range_in_years: "5_to_11", subjects: [primary])] }

          it "shows it" do
            expect(result_card).to have_text("Ages 5 to 11")
          end
        end
      end

      context "when a further education course is on its own card" do
        let(:courses) { [create(:course, :further_education, provider:, age_range_in_years: "14_to_19")] }

        it "shows it" do
          expect(result_card).to have_text("Ages 14 to 19")
        end
      end
    end

    context "without grouped results" do
      let(:courses) { [fee_course] }

      before { fee_course.update!(age_range_in_years: "11_to_16") }

      it "shows it on a secondary course, as today" do
        expect(result_card).to have_text("Ages 11 to 16")
      end
    end
  end
end
