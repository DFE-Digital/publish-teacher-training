# frozen_string_literal: true

require "rails_helper"

RSpec.describe Courses::SummaryCardComponent, type: :component do
  include Rails.application.routes.url_helpers

  subject(:summary_card_content) do
    summary_card.text.gsub(/\r?\n/, " ").squeeze(" ").strip
  end

  let(:summary_card) do
    render_inline(
      described_class.new(
        course:,
        location:,
        visa_sponsorship:,
      ),
    )
  end
  let(:search_params) { {} }
  let(:location) { search_params[:location] }
  let(:visa_sponsorship) { search_params[:can_sponsor_visa] }

  describe "#title" do
    let(:course) do
      build(
        :course,
        name: "Mathematics",
        course_code: "37CP",
        provider: build(:provider, provider_code: "B1T", provider_name: "University"),
      )
    end

    it "renders the provider name in the title without a link" do
      expect(summary_card).to have_css(".govuk-summary-card__title .app-search-result__provider-name", text: "University")
      expect(summary_card).not_to have_css(".govuk-summary-card__title a")
    end

    it "renders the course name and code as a link at the top of the content" do
      expect(summary_card).to have_css(
        ".govuk-summary-card__content a.app-search-result__course-name",
        text: "Mathematics (37CP)",
      )
      expect(summary_card).to have_link("Mathematics (37CP)", href: find_course_path(provider_code: "B1T", course_code: "37CP"))
    end

    context "when the course is closed" do
      let(:course) { create(:course, :closed, name: "Mathematics", course_code: "37CP") }

      it "renders the not accepting applications status tag" do
        expect(summary_card).to have_css(".app-saved-course__status-tag", text: "Not accepting applications")
      end
    end

    context "when the course is not yet open", travel: 1.day.after(find_opens) do
      let(:course) { create(:course, :open, name: "Mathematics", course_code: "37CP") }

      it "does not render the not yet open status tag" do
        expect(summary_card).not_to have_css(".app-saved-course__status-tag", text: "Not yet open")
      end
    end
  end

  shared_examples "school location row" do |funding_type, expected_output|
    let(:funding) { funding_type }

    it "returns the correct content for #{funding_type} when course has school(s)" do
      expect(summary_card_content).to include(expected_output)
    end
  end

  describe "when displaying location field" do
    let(:course) do
      create(
        :course,
        funding:,
      )
    end

    context "when not searching by location" do
      it_behaves_like "school location row", :fee, "Search by city, town or postcode to find the nearest potential placement school"

      context "when funding is 'fee'" do
        let(:funding) { :fee }

        it "renders the hint without a nearest school heading or distance" do
          expect(summary_card).to have_css(".govuk-hint.govuk-\\!-font-size-16", text: "Search by city, town or postcode")
          expect(summary_card_content).not_to include("Nearest placement school")
          expect(summary_card).not_to have_css(".govuk-summary-list__key", text: "Nearest placement school")
        end
      end
    end
  end

  describe "when published without an employing school" do
    let(:course) do
      create(:course, funding:, publish_without_schools_allowed: true)
    end

    context "when funding is 'salary'" do
      let(:funding) { :salary }

      it "shows 'No employing schools listed' as the value" do
        expect(summary_card_content).to include("No employing schools listed")
      end

      it "does not render a nearest school distance" do
        expect(summary_card_content).not_to include("Nearest employing school")
      end

      it "does not show the misleading search-by-location hint" do
        expect(summary_card_content).not_to include("Search by city, town or postcode")
      end
    end

    context "when funding is 'apprenticeship'" do
      let(:funding) { :apprenticeship }

      it "shows 'No employing schools listed' as the value" do
        expect(summary_card_content).to include("No employing schools listed")
      end
    end

    context "when funding is 'fee'" do
      let(:funding) { :fee }

      it "shows 'No employing schools listed' as the value" do
        expect(summary_card_content).to include("No employing schools listed")
      end
    end

    context "when the salaried course does have a school attached" do
      let(:funding) { :salary }

      before { create(:course_school, course:) }

      it "does not show 'No employing schools listed'" do
        expect(summary_card_content).not_to include("No employing schools listed")
      end
    end
  end

  describe "displaying location value" do
    let(:course) do
      create(
        :course,
        funding:,
      )
    end

    context "when there are placements and is not a location search" do
      it_behaves_like "school location row", :fee, "Search by city, town or postcode to find the nearest potential placement school"
      it_behaves_like "school location row", :salary, "Search by city, town or postcode to find the nearest potential employing school"
      it_behaves_like "school location row", :apprenticeship, "Search by city, town or postcode to find the nearest potential employing school"
    end

    describe "#search_by_location?" do
      subject(:summary_card) do
        described_class.new(
          course:,
          location:,
          visa_sponsorship: false,
        )
      end

      let(:location) { "London" }
      let(:funding) { "fee" }

      context "when there is a minimum distance" do
        before do
          # minimum_distance_to_search_location will be an attribute
          # in the query SELECT list so we avoid Ruby computation and
          # recalculation of all sites and its latitude, longitude from a single
          # location
          course.define_singleton_method(:minimum_distance_to_search_location) { 0.2 }
        end

        it "returns true" do
          expect(summary_card.search_by_location?).to be true
        end
      end

      context "when there is not a minimum distance" do
        it "returns false" do
          expect(summary_card.search_by_location?).to be false
          expect { render_inline(summary_card) }.not_to raise_error
        end
      end

      context "when there is no location params" do
        let(:location) { nil }

        it "returns false" do
          expect(summary_card.search_by_location?).to be false
        end
      end
    end

    context "when search by location" do
      let(:search_params) { { location: "London", latitude: 1, longitude: 1 } }

      before do
        # minimum_distance_to_search_location will be an attribute
        # in the query SELECT list so we avoid Ruby computation and
        # recalculation of all sites and its latitude, longitude from a single
        # location
        course.define_singleton_method(:minimum_distance_to_search_location) { 0.2 }
      end

      it_behaves_like "school location row", :fee, "Nearest placement school 1 mile from London"
      it_behaves_like "school location row", :salary, "Nearest employing school 1 mile from London"
      it_behaves_like "school location row", :apprenticeship, "Nearest employing school 1 mile from London"

      context "when funding is 'fee'" do
        let(:funding) { :fee }

        it "renders the distance in bold and the search location as a hint underneath" do
          expect(summary_card).to have_css("p", text: "Nearest placement school 1 mile")
          expect(summary_card).to have_css("strong", text: "1 mile")
          expect(summary_card).to have_css(".govuk-hint.govuk-\\!-font-size-16", text: "from London")
        end

        it "does not render the search by location hint" do
          expect(summary_card_content).not_to include("Search by city, town or postcode")
        end
      end

      context "when the nearest school is further than a mile" do
        let(:funding) { :fee }

        before { course.define_singleton_method(:minimum_distance_to_search_location) { 4.3 } }

        it "rounds up and pluralises the distance" do
          expect(summary_card).to have_css("strong", text: "5 miles")
        end
      end

      context "when the search has a short address" do
        let(:funding) { :fee }
        let(:summary_card) do
          render_inline(described_class.new(course:, location: "London, UK", short_address: "London"))
        end

        it "uses the short address" do
          expect(summary_card).to have_css(".govuk-hint", text: /\Afrom London\z/)
        end
      end

      context "sanitize dangerous user input" do
        let(:funding) { :fee }
        let(:search_params) do
          { location: '<script>alert("XSS")</script>', latitude: 1, longitude: 1 }
        end

        it "sanitizes user input by striping html tags" do
          expect(summary_card_content).to include(
            'Nearest placement school 1 mile from alert("XSS")',
          )
        end
      end
    end
  end

  describe "when displaying funding" do
    before do
      FeatureFlag.activate(:bursaries_and_scholarships_announced)
    end

    def fee_course(subjects:, fee_uk_eu: 9790, fee_international: 29_790)
      create(
        :course,
        :secondary,
        :fee_type_based,
        name: "Physics with Drama",
        subjects:,
        enrichments: [create(:course_enrichment, :published, fee_uk_eu:, fee_international:)],
      )
    end

    context "when course funding is salary" do
      let(:course) { create(:course, funding: :salary) }

      it "shows salary without bursaries or scholarships" do
        expect(summary_card_content).to include("Salary")
        expect(summary_card_content).not_to include("fee for UK citizens")
        expect(summary_card_content).not_to include("Bursaries")
        expect(summary_card_content).not_to include("Scholarships")
      end
    end

    context "when course funding is apprenticeship" do
      let(:course) { create(:course, funding: :apprenticeship) }

      it "shows apprenticeship (salary) without bursaries or scholarships" do
        expect(summary_card_content).to include("Apprenticeship (salary)")
        expect(summary_card_content).not_to include("Salary (apprenticeship)")
        expect(summary_card_content).not_to include("Bursaries")
        expect(summary_card_content).not_to include("Scholarships")
      end
    end

    context "when the course has UK and non-UK fees and no financial incentive" do
      let(:course) { fee_course(subjects: [build(:secondary_subject, :dance), build(:secondary_subject, :drama)]) }

      it "shows the UK fee with the non-UK fee on the next line" do
        expect(summary_card.to_html).to include("£9,790 fee for UK citizens<br>£29,790 fee for non-UK citizens")
      end

      it "does not show a bursaries hint" do
        expect(summary_card_content).not_to include("Bursaries")
      end

      it "no longer renders the fee or salary key or the bold fee" do
        expect(summary_card_content).not_to include("Fee or salary")
        expect(summary_card).not_to have_css("b", text: "fee")
      end
    end

    context "when the course only has a UK fee" do
      let(:course) { fee_course(subjects: [build(:secondary_subject, :dance)], fee_international: nil) }

      it "shows only the UK fee" do
        expect(summary_card_content).to include("£9,790 fee for UK citizens")
        expect(summary_card_content).not_to include("non-UK citizens")
      end
    end

    context "when the main subject offers a bursary" do
      let(:course) { fee_course(subjects: [build(:secondary_subject, :dance, bursary_amount: 9000), build(:secondary_subject, :drama)]) }

      it "shows bursaries available as a hint after the UK fee, without the amount" do
        expect(summary_card_content).to include("£9,790 fee for UK citizens - Bursaries available")
        expect(summary_card.to_html).to include("- Bursaries available</span><br>£29,790 fee for non-UK citizens")
        expect(summary_card).to have_css("span.govuk-hint.govuk-\\!-font-size-16", text: "- Bursaries available")
        expect(summary_card_content).not_to include("£9,000")
      end
    end

    context "when the bursary is not available to non-UK citizens" do
      let(:course) { fee_course(subjects: [build(:secondary_subject, :english, bursary_amount: 6000), build(:secondary_subject, :drama)]) }

      it "shows bursaries available without a UK citizens qualifier" do
        expect(summary_card_content).to include("- Bursaries available")
        expect(summary_card_content).not_to include("to UK citizens")
      end
    end

    context "when the main subject offers a bursary and a scholarship" do
      let(:course) { fee_course(subjects: [build(:secondary_subject, :physics, bursary_amount: 7000, scholarship: 9000), build(:secondary_subject, :drama)]) }

      it "shows bursaries available and does not mention scholarships" do
        expect(summary_card_content).to include("- Bursaries available")
        expect(summary_card_content).not_to include("Scholarships")
      end
    end

    context "when the main subject only offers a scholarship" do
      let(:course) { fee_course(subjects: [build(:secondary_subject, :dance, scholarship: 9000), build(:secondary_subject, :drama)]) }

      it "does not show a financial incentive hint" do
        expect(summary_card_content).not_to include("Bursaries")
        expect(summary_card_content).not_to include("Scholarships")
      end
    end

    context "when only the second subject offers a bursary" do
      let(:course) { fee_course(subjects: [build(:secondary_subject, :drama), build(:secondary_subject, :physics, bursary_amount: 9000)]) }

      it "does not show a bursaries hint" do
        expect(summary_card_content).not_to include("Bursaries")
      end
    end

    context "when bursaries and scholarships have not been announced" do
      before { FeatureFlag.deactivate(:bursaries_and_scholarships_announced) }

      let(:course) { fee_course(subjects: [build(:secondary_subject, :dance, bursary_amount: 9000)]) }

      it "does not show a bursaries hint" do
        expect(summary_card_content).not_to include("Bursaries")
      end
    end
  end

  shared_examples "course length row" do |course_length, course_study_mode, expected_output|
    let(:course) do
      create(:course, study_mode:, enrichments: [build(:course_enrichment, :published, course_length: length)])
    end
    let(:length) { course_length }
    let(:study_mode) { course_study_mode }

    it "returns the correct course length row for #{course_length} and #{course_study_mode}" do
      expect(summary_card_content).to include("Course length#{expected_output}")
    end
  end

  describe "when displaying course length" do
    context "when course length is one year" do
      it_behaves_like "course length row", "OneYear", :full_time, "1 year - full time"
      it_behaves_like "course length row", "OneYear", :part_time, "1 year - part time"
      it_behaves_like "course length row", "OneYear", :full_time_or_part_time, "1 year - full time or part time"
    end

    context "when course length is two years" do
      it_behaves_like "course length row", "TwoYears", :full_time, "Up to 2 years - full time"
      it_behaves_like "course length row", "TwoYears", :part_time, "Up to 2 years - part time"
      it_behaves_like "course length row", "TwoYears", :full_time_or_part_time, "Up to 2 years - full time or part time"
    end

    context "when custom course length" do
      it_behaves_like "course length row", "4 years", :full_time, "4 years - full time"
      it_behaves_like "course length row", "4 years", :part_time, "4 years - part time"
      it_behaves_like "course length row", "4 years", :full_time_or_part_time, "4 years - full time or part time"
    end
  end

  describe "when displaying the age range" do
    let(:course) { create(:course, name: "Mathematics", course_code: "37CP", age_range_in_years:) }

    %w[3_to_7 5_to_14 11_to_16 14_to_19].each do |range|
      context "when the age range is #{range}" do
        let(:age_range_in_years) { range }

        it "renders the age range as a hint under the course name" do
          expect(summary_card).to have_css(
            ".govuk-summary-card__content .govuk-hint.govuk-\\!-font-size-16",
            text: "Ages #{range.humanize}",
          )
          expect(summary_card_content).to include("Mathematics (37CP) Ages #{range.humanize}")
        end
      end
    end

    context "when the course has an age range" do
      let(:age_range_in_years) { "11_to_16" }

      it "does not render the old age group row" do
        expect(summary_card_content).not_to include("Age group")
      end
    end

    context "when course is further education" do
      let(:course) { create(:course, :further_education, age_range_in_years: nil) }

      it "does not render an age range" do
        expect(summary_card_content).not_to include("Ages")
      end
    end
  end

  describe "when displaying qualification and study type" do
    {
      qts: "QTS",
      pgce_with_qts: "QTS with PGCE",
      pgde_with_qts: "QTS with PGDE",
      pgce: "PGCE without QTS",
      pgde: "PGDE without QTS",
      undergraduate_degree_with_qts: "Teacher degree apprenticeship with QTS",
    }.each do |qualification, expected_qualification|
      context "when the qualification is #{qualification}" do
        let(:course) { create(:course, qualification:, study_mode: :full_time) }

        it "shows the qualification followed by the study type" do
          expect(summary_card_content).to include("#{expected_qualification}, full time")
        end
      end
    end

    {
      full_time: "full time",
      part_time: "part time",
      full_time_or_part_time: "full time or part time",
    }.each do |study_mode, expected_study_mode|
      context "when the study mode is #{study_mode}" do
        let(:course) { create(:course, qualification: :pgce_with_qts, study_mode:) }

        it "shows #{expected_study_mode}" do
          expect(summary_card_content).to include("QTS with PGCE, #{expected_study_mode}")
        end
      end
    end

    context "when the qualification is QTS" do
      let(:course) { create(:course, qualification: :qts) }

      it "keeps the abbreviation but drops 'only'" do
        expect(summary_card).to have_css("abbr[title='Qualified teacher status']", text: "QTS")
        expect(summary_card_content).not_to include("QTS only")
        expect(summary_card_content).not_to include("Qualification awarded")
      end
    end
  end

  describe "when displaying school experience" do
    let(:cycle_year) { 2027 }
    let(:course) do
      create(
        :course,
        :with_salary,
        school_experience_required:,
        school_experience_required_content: school_experience_required ? "Requires a Nobel prize" : nil,
        provider: build(:provider, recruitment_cycle: find_or_create(:recruitment_cycle, year: cycle_year)),
      )
    end

    context "when the course is in the 2027 cycle or later and school experience is required" do
      let(:school_experience_required) { true }

      it "displays the school experience row" do
        expect(summary_card_content).to include("School experienceRequired or strongly recommended")
      end
    end

    context "when school experience is not required" do
      let(:school_experience_required) { false }

      it "does not display the school experience row" do
        expect(summary_card_content).not_to include("School experience")
      end
    end

    context "when the course is in a cycle before 2027" do
      let(:cycle_year) { 2026 }
      let(:school_experience_required) { true }

      it "does not display the school experience row" do
        expect(summary_card_content).not_to include("School experience")
      end
    end
  end

  shared_examples "course degree requirements row" do |course_degree_type, course_degree_grade_required, expected_output|
    let(:course) { create(:course, degree_type:, degree_grade:) }
    let(:degree_type) { course_degree_type }
    let(:degree_grade) { course_degree_grade_required }

    it "returns the correct degree requirements row for #{course_degree_type} and #{course_degree_grade_required}" do
      expect(summary_card_content).to include("Degree required #{expected_output}")
    end
  end

  describe "when displaying course degree requirements" do
    context "when course requires 2:1 degree" do
      it_behaves_like "course degree requirements row", :postgraduate, "two_one", "2:1 bachelor’s degree or above or equivalent qualification"
    end

    context "when course requires 2:2 degree" do
      it_behaves_like "course degree requirements row", :postgraduate, "two_two", "2:2 bachelor’s degree or above or equivalent qualification"
    end

    context "when course requires third class degree" do
      it_behaves_like "course degree requirements row",
                      :postgraduate,
                      "third_class",
                      "Bachelor’s degree or equivalent qualification This should be an honours degree (Third or above), or equivalent"
    end

    context 'when course requires "Pass" degree' do
      it_behaves_like "course degree requirements row", :postgraduate, "not_required", "Bachelor’s degree or equivalent qualification"
    end

    context "when course requires no degree" do
      it_behaves_like "course degree requirements row", :undergraduate, "not_required", "No degree required"

      it "does not render the hint text" do
        course = create(:course, degree_type: "undergraduate", degree_grade: "not_required")
        expect(render_inline(described_class.new(course:))).not_to include("or equivalent qualification")
      end
    end
  end

  shared_examples "visa sponsorship row" do |funding, visa_sponsorship, expected_text|
    let(:course) do
      create(
        :course,
        funding:,
        can_sponsor_student_visa:,
        can_sponsor_skilled_worker_visa:,
      )
    end
    let(:can_sponsor_student_visa) { visa_sponsorship[:can_sponsor_student_visa] }
    let(:can_sponsor_skilled_worker_visa) { visa_sponsorship[:can_sponsor_skilled_worker_visa] }

    it "displays the correct visa sponsorship text for #{funding} courses with #{visa_sponsorship}" do
      expect(summary_card_content).to include("Visa sponsorship#{expected_text}")
    end
  end

  describe "when displaying course visa sponsorship" do
    context "when the provider sponsor skilled worker visa for a salaried course" do
      it_behaves_like "visa sponsorship row", :salary, { can_sponsor_skilled_worker_visa: true }, "Skilled Worker visas can be sponsored"
      it_behaves_like "visa sponsorship row", :apprenticeship, { can_sponsor_skilled_worker_visa: true }, "Skilled Worker visas can be sponsored"
    end

    context "when the provider sponsor skilled worker visa sponsorship for an unsalaried course" do
      it_behaves_like "visa sponsorship row", :fee, { can_sponsor_skilled_worker_visa: true }, "Visas cannot be sponsored"
    end

    context "when the provider specifies student visa sponsorship for an salaried course" do
      it_behaves_like "visa sponsorship row", :salary, { can_sponsor_student_visa: true }, "Visas cannot be sponsored"
      it_behaves_like "visa sponsorship row", :apprenticeship, { can_sponsor_student_visa: true }, "Visas cannot be sponsored"
    end

    context "when the provider specifies student visa sponsorship for an unsalaried course" do
      it_behaves_like "visa sponsorship row", :fee, { can_sponsor_student_visa: true }, "Student visas can be sponsored"
    end

    context "when neither kind of visa is sponsored" do
      it_behaves_like "visa sponsorship row", :fee, { can_sponsor_student_visa: false }, "Visas cannot be sponsored"
      it_behaves_like "visa sponsorship row", :salary, { can_sponsor_student_visa: false }, "Visas cannot be sponsored"
      it_behaves_like "visa sponsorship row", :apprenticeship, { can_sponsor_student_visa: false }, "Visas cannot be sponsored"
    end
  end
end
