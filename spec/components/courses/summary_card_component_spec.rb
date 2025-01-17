# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Courses::SummaryCardComponent, type: :component do
  include Rails.application.routes.url_helpers

  subject(:summary_card_content) do
    summary_card.text.gsub(/\r?\n/, ' ').squeeze(' ').strip
  end

  let(:summary_card) do
    render_inline(
      described_class.new(
        course:,
        location:,
        visa_sponsorship:
      )
    )
  end
  let(:search_params) { {} }
  let(:location) { search_params[:location] }
  let(:visa_sponsorship) { search_params[:can_sponsor_visa] }

  describe '#title' do
    let(:course) do
      build(
        :course,
        name: 'Mathematics',
        course_code: '37CP',
        provider: build(:provider, provider_code: 'B1T', provider_name: 'University')
      )
    end

    it 'renders the correct link with provider and course name' do
      expect(summary_card).to have_link('University', href: find_course_path(provider_code: 'B1T', course_code: '37CP'))
    end

    it 'renders the provider name with the correct class' do
      expect(summary_card).to have_css('.app-search-result__provider-name', text: 'University')
    end

    it 'renders the course name and code with the correct class' do
      expect(summary_card).to have_css('.app-search-result__course-name', text: 'Mathematics (37CP)')
    end
  end

  shared_examples 'school location row' do |funding_type, count, expected_output|
    let(:funding) { funding_type }
    let(:available_placements_count) { count }

    before { allow(course).to receive(:available_placements_count).and_return(count) }

    it "returns the correct content for #{funding_type} when course has #{count} school(s)" do
      expect(summary_card_content).to include(expected_output)
    end
  end

  describe 'when displaying location field' do
    let(:course) do
      create(
        :course,
        funding:
      )
    end

    context "when funding is 'fee'" do
      it_behaves_like 'school location row', :fee, 1, 'Placement school'
      it_behaves_like 'school location row', :fee, 3, 'Placement schools'
    end

    context "when funding is 'salary'" do
      it_behaves_like 'school location row', :salary, 1, 'Employing school'
      it_behaves_like 'school location row', :salary, 5, 'Employing schools'
    end

    context "when funding is 'apprenticeship'" do
      it_behaves_like 'school location row', :apprenticeship, 1, 'Employing school'
      it_behaves_like 'school location row', :apprenticeship, 7, 'Employing schools'
    end
  end

  describe 'displaying location value' do
    let(:course) do
      create(
        :course,
        funding:
      )
    end

    context 'when no placements' do
      it_behaves_like 'school location row', :fee, 0, 'Not listed yet'
      it_behaves_like 'school location row', :salary, 0, 'Not listed yet'
      it_behaves_like 'school location row', :apprenticeship, 0, 'Not listed yet'
    end

    context 'when there are placements and is not a location search' do
      it_behaves_like 'school location row', :fee, 1, '1 potential placement school'
      it_behaves_like 'school location row', :fee, 2, '2 potential placement schools'
      it_behaves_like 'school location row', :salary, 1, '1 potential employing school'
      it_behaves_like 'school location row', :salary, 2, '2 potential employing schools'
      it_behaves_like 'school location row', :apprenticeship, 1, '1 potential employing school'
      it_behaves_like 'school location row', :apprenticeship, 3, '3 potential employing schools'
    end

    context 'when search by location' do
      let(:search_params) { { location: 'London', latitude: 1, longitude: 1 } }

      before do
        # minimum_distance_to_search_location will be an attribute
        # in the query SELECT list so we avoid Ruby computation and
        # recalculation of all sites and its latitude, longitude from a single
        # location
        course.define_singleton_method(:minimum_distance_to_search_location) { 0.2 }
      end

      it_behaves_like 'school location row', :fee, 3, '0.2 miles from London'
      it_behaves_like 'school location row', :salary, 3, '0.2 miles from London'
      it_behaves_like 'school location row', :apprenticeship, 3, '0.2 miles from London'

      it_behaves_like 'school location row', :fee, 1, 'Nearest of 1 potential placement school'
      it_behaves_like 'school location row', :fee, 3, 'Nearest of 3 potential placement schools'
      it_behaves_like 'school location row', :salary, 1, 'Nearest of 1 potential employing school'
      it_behaves_like 'school location row', :salary, 3, 'Nearest of 3 potential employing schools'
      it_behaves_like 'school location row', :apprenticeship, 1, 'Nearest of 1 potential employing school'
      it_behaves_like 'school location row', :apprenticeship, 3, 'Nearest of 3 potential employing schools'

      context 'sanitize dangerous user input' do
        let(:funding) { :fee }
        let(:search_params) do
          { location: '<script>alert("XSS")</script>', latitude: 1, longitude: 1 }
        end

        before { allow(course).to receive(:available_placements_count).and_return(2) }

        it 'sanitizes user input by striping html tags' do
          expect(summary_card_content).to include(
            '0.2 miles from alert("XSS") Nearest of 2 potential placement schools'
          )
        end
      end
    end
  end

  shared_examples 'fee or salary row' do |funding_type, params, expected_output|
    let(:funding) { funding_type }
    let(:search_params) { params }

    before { allow(course).to receive(:available_placements_count).and_return(2) }

    it "returns the correct fee or salary row for #{funding_type}" do
      expect(summary_card_content).to include(expected_output)
    end
  end

  describe 'when displaying fee or salary' do
    let(:course) do
      create(
        :course,
        funding:
      )
    end

    before do
      FeatureFlag.activate(:bursaries_and_scholarships_announced)
    end

    context 'when course funding is salary' do
      let(:funding) { :salary }

      it 'does not show bursaries or scholarship' do
        expect(summary_card_content).to include('Salary')
        expect(summary_card_content).not_to include('Bursaries')
        expect(summary_card_content).not_to include('Scholarships')
      end
    end

    context 'when course funding is apprenticeship' do
      let(:funding) { :apprenticeship }

      it 'does not show bursaries or scholarship' do
        expect(summary_card_content).to include('Salary (apprenticeship)')
        expect(summary_card_content).not_to include('Bursaries')
        expect(summary_card_content).not_to include('Scholarships')
      end
    end

    context 'when course funding is fee and user searches for visa sponsorship' do
      context 'when physics is main subject and has bursaries' do
        let(:course) do
          create(
            :course,
            :secondary,
            name: 'Physics with Drama',
            subjects: [
              build(:secondary_subject, :physics, bursary_amount: 10_000),
              build(:secondary_subject, :drama)
            ],
            funding:,
            enrichments: [create(:course_enrichment, fee_uk_eu: 9250, fee_international: 17_900)]
          )
        end

        it_behaves_like 'fee or salary row', :fee, { can_sponsor_visa: true }, '£9,250 for UK citizens'
        it_behaves_like 'fee or salary row', :fee, { can_sponsor_visa: true }, '£17,900 for Non-UK citizens'
        it_behaves_like 'fee or salary row', :fee, { can_sponsor_visa: true }, 'Bursaries of £10,000 are available'
      end

      context 'when physics is main subject and has scholarship' do
        let(:course) do
          create(
            :course,
            :secondary,
            name: 'Physics with Drama',
            subjects: [
              build(:secondary_subject, :physics, scholarship: 10_000),
              build(:secondary_subject, :drama)
            ],
            funding:,
            enrichments: [create(:course_enrichment, fee_uk_eu: 6000, fee_international: 11_000)]
          )
        end

        it_behaves_like 'fee or salary row', :fee, { can_sponsor_visa: true }, '£6,000 for UK citizens'
        it_behaves_like 'fee or salary row', :fee, { can_sponsor_visa: true }, '£11,000 for Non-UK citizens'
        it_behaves_like 'fee or salary row', :fee, { can_sponsor_visa: true }, 'Scholarships of £10,000 are available'
      end

      context 'when physics is main subject and has bursaries and scholarship' do
        let(:course) do
          create(
            :course,
            :secondary,
            name: 'Physics with Drama',
            subjects: [
              build(:secondary_subject, :physics, bursary_amount: 9000, scholarship: 10_000),
              build(:secondary_subject, :drama)
            ],
            funding:,
            enrichments: [create(:course_enrichment, fee_uk_eu: 7000, fee_international: 7000)]
          )
        end

        it_behaves_like 'fee or salary row', :fee, { can_sponsor_visa: true }, '£7,000 for UK citizens'
        it_behaves_like 'fee or salary row', :fee, { can_sponsor_visa: true }, '£7,000 for Non-UK citizens'
        it_behaves_like 'fee or salary row', :fee, { can_sponsor_visa: true }, 'Scholarships of £10,000 or bursaries of £9,000 are available'
      end

      context 'when main subject does not have bursaries and physics is second subject with bursaries' do
        let(:course) do
          create(
            :course,
            :secondary,
            :fee_type_based,
            name: 'Physics with Drama',
            subjects: [
              build(:secondary_subject, :drama),
              build(:secondary_subject, :physics, bursary_amount: 9000, scholarship: 10_000)
            ],
            enrichments: [create(:course_enrichment, fee_uk_eu: 8000, fee_international: 8000)]
          )
        end

        it_behaves_like 'fee or salary row', :fee, { can_sponsor_visa: true }, '£8,000 for UK citizens'
        it_behaves_like 'fee or salary row', :fee, { can_sponsor_visa: true }, '£8,000 for Non-UK citizens'

        it 'does not show bursaries or scholarship' do
          expect(summary_card_content).not_to include('Bursaries')
          expect(summary_card_content).not_to include('Scholarships')
        end
      end

      context 'when languages is the main subject and offer bursaries and scholarship' do
        let(:course) do
          create(
            :course,
            :secondary,
            name: 'English with Drama',
            subjects: [
              build(:secondary_subject, :english, bursary_amount: 6000, scholarship: 5000),
              build(:secondary_subject, :drama)
            ],
            funding:,
            enrichments: [create(:course_enrichment, fee_uk_eu: 10_000, fee_international: nil)]
          )
        end

        it_behaves_like 'fee or salary row', :fee, { can_sponsor_visa: true }, '£10,000 for UK citizens'
        it_behaves_like 'fee or salary row', :fee, { can_sponsor_visa: true }, 'Scholarships of £5,000 or bursaries of £6,000 are available'
      end

      context 'when languages is the second subject' do
        let(:course) do
          create(
            :course,
            :secondary,
            :fee_type_based,
            name: 'Physics with Drama',
            subjects: [
              build(:secondary_subject, :drama),
              build(:secondary_subject, :physics, bursary_amount: 9000, scholarship: 10_000)
            ],
            enrichments: [create(:course_enrichment, fee_uk_eu: 6250, fee_international: 6900)]
          )
        end

        it_behaves_like 'fee or salary row', :fee, { can_sponsor_visa: true }, '£6,250 for UK citizens'
        it_behaves_like 'fee or salary row', :fee, { can_sponsor_visa: true }, '£6,900 for Non-UK citizens'

        it 'does not show bursaries or scholarship' do
          expect(summary_card_content).not_to include('Bursaries')
          expect(summary_card_content).not_to include('Scholarships')
        end
      end

      context 'when is not physics' do
        let(:course) do
          create(
            :course,
            :secondary,
            :fee_type_based,
            name: 'History with Drama',
            subjects: [
              build(:secondary_subject, :history, bursary_amount: 9000, scholarship: 10_000),
              build(:secondary_subject, :drama)
            ],
            enrichments: [create(:course_enrichment, fee_uk_eu: 6250, fee_international: nil)]
          )
        end
        let(:search_params) { { can_sponsor_visa: true } }

        it 'does not show bursaries or scholarship' do
          expect(summary_card_content).not_to include('Bursaries')
          expect(summary_card_content).not_to include('Scholarships')
        end
      end

      context 'when is not languages' do
        let(:course) do
          create(
            :course,
            :secondary,
            :fee_type_based,
            name: 'Biology with Drama',
            subjects: [
              build(:secondary_subject, :biology, bursary_amount: 9000, scholarship: 10_000),
              build(:secondary_subject, :drama)
            ]
          )
        end
        let(:search_params) { { can_sponsor_visa: true } }

        it 'does not show bursaries or scholarship' do
          expect(summary_card_content).not_to include('Bursaries')
          expect(summary_card_content).not_to include('Scholarships')
        end
      end
    end

    context 'when course funding is fee and user does not search for visa sponsorship' do
      context 'when main subject offers bursary' do
        let(:course) do
          create(
            :course,
            :secondary,
            :fee_type_based,
            name: 'Dance with Drama',
            subjects: [
              build(:secondary_subject, :dance, bursary_amount: 9000),
              build(:secondary_subject, :drama)
            ],
            enrichments: [create(:course_enrichment, fee_uk_eu: 6250, fee_international: 6900)]
          )
        end

        it_behaves_like 'fee or salary row', :fee, {}, '£6,250 for UK citizens'
        it_behaves_like 'fee or salary row', :fee, {}, '£6,900 for Non-UK citizens'
        it_behaves_like 'fee or salary row', :fee, {}, 'Bursaries of £9,000 are available'
      end

      context 'when main subject offers scholarship' do
        let(:course) do
          create(
            :course,
            :secondary,
            :fee_type_based,
            name: 'Dance with Drama',
            subjects: [
              build(:secondary_subject, :dance, scholarship: 9000),
              build(:secondary_subject, :drama)
            ],
            enrichments: [create(:course_enrichment, fee_uk_eu: 6250, fee_international: 6900)]
          )
        end

        it_behaves_like 'fee or salary row', :fee, {}, '£6,250 for UK citizens'
        it_behaves_like 'fee or salary row', :fee, {}, '£6,900 for Non-UK citizens'
        it_behaves_like 'fee or salary row', :fee, {}, 'Scholarships of £9,000 are available'
      end

      context 'when main subject offers bursaries and scholarship' do
        let(:course) do
          create(
            :course,
            :secondary,
            :fee_type_based,
            name: 'Dance with Drama',
            subjects: [
              build(:secondary_subject, :dance, bursary_amount: 7000, scholarship: 9000),
              build(:secondary_subject, :drama)
            ],
            enrichments: [create(:course_enrichment, fee_uk_eu: 7250, fee_international: 6900)]
          )
        end

        it_behaves_like 'fee or salary row', :fee, {}, '£7,250 for UK citizens'
        it_behaves_like 'fee or salary row', :fee, {}, '£6,900 for Non-UK citizens'
        it_behaves_like 'fee or salary row', :fee, {}, 'Scholarships of £9,000 or bursaries of £7,000 are available'
      end

      context 'when main subject does not offer bursary or scholarship' do
        let(:course) do
          create(
            :course,
            :secondary,
            :fee_type_based,
            name: 'Dance with Drama',
            subjects: [
              build(:secondary_subject, :drama),
              build(:secondary_subject, :dance, bursary_amount: 7000, scholarship: 9000)
            ],
            enrichments: [create(:course_enrichment, fee_uk_eu: 7500, fee_international: 6900)]
          )
        end

        it_behaves_like 'fee or salary row', :fee, {}, '£7,500 for UK citizens'
        it_behaves_like 'fee or salary row', :fee, {}, '£6,900 for Non-UK citizens'

        it 'does not show bursaries or scholarship' do
          expect(summary_card_content).not_to include('Bursaries')
          expect(summary_card_content).not_to include('Scholarships')
        end
      end

      context 'when all subjects does not offer bursary or scholarship' do
        let(:course) do
          create(
            :course,
            :secondary,
            :fee_type_based,
            name: 'Dance with Drama',
            subjects: [
              build(:secondary_subject, :dance),
              build(:secondary_subject, :drama)
            ],
            enrichments: [create(:course_enrichment, fee_uk_eu: 8500, fee_international: 8500)]
          )
        end

        it_behaves_like 'fee or salary row', :fee, {}, '£8,500 for UK citizens'
        it_behaves_like 'fee or salary row', :fee, {}, '£8,500 for Non-UK citizens'

        it 'does not show bursaries or scholarship' do
          expect(summary_card_content).not_to include('Bursaries')
          expect(summary_card_content).not_to include('Scholarships')
        end
      end
    end
  end

  shared_examples 'course length row' do |course_length, course_study_mode, expected_output|
    let(:course) do
      create(:course, study_mode:, enrichments: [build(:course_enrichment, course_length: length)])
    end
    let(:length) { course_length }
    let(:study_mode) { course_study_mode }

    before { allow(course).to receive(:available_placements_count).and_return(2) }

    it "returns the correct course length row for #{course_length} and #{course_study_mode}" do
      expect(summary_card_content).to include("Course length#{expected_output}")
    end
  end

  describe 'when displaying course length' do
    context 'when course length is one year' do
      it_behaves_like 'course length row', 'OneYear', :full_time, '1 year - full time'
      it_behaves_like 'course length row', 'OneYear', :part_time, '1 year - part time'
      it_behaves_like 'course length row', 'OneYear', :full_time_or_part_time, '1 year - full time or part time'
    end

    context 'when course length is two years' do
      it_behaves_like 'course length row', 'TwoYears', :full_time, 'Up to 2 years - full time'
      it_behaves_like 'course length row', 'TwoYears', :part_time, 'Up to 2 years - part time'
      it_behaves_like 'course length row', 'TwoYears', :full_time_or_part_time, 'Up to 2 years - full time or part time'
    end

    context 'when custom course length' do
      it_behaves_like 'course length row', '4 years', :full_time, '4 years - full time'
      it_behaves_like 'course length row', '4 years', :part_time, '4 years - part time'
      it_behaves_like 'course length row', '4 years', :full_time_or_part_time, '4 years - full time or part time'
    end
  end

  shared_examples 'course age group row' do |course_level, course_age_group, expected_output|
    let(:course) { create(:course, level:, age_range_in_years:) }
    let(:level) { course_level.downcase }
    let(:age_range_in_years) { course_age_group }

    before { allow(course).to receive(:available_placements_count).and_return(2) }

    it "returns the correct age group row for #{course_level} and #{course_age_group}" do
      expect(summary_card_content).to include("Age group#{expected_output}")
    end
  end

  describe 'when displaying age group' do
    context 'when course is primary' do
      it_behaves_like 'course age group row', 'Primary', '3_to_11', 'Primary - 3 to 11'
      it_behaves_like 'course age group row', 'Primary', '3_to_7', 'Primary - 3 to 7'
      it_behaves_like 'course age group row', 'Primary', '4_to_11', 'Primary - 4 to 11'
      it_behaves_like 'course age group row', 'Primary', '5_to_11', 'Primary - 5 to 11'
      it_behaves_like 'course age group row', 'Primary', '5_to_14', 'Primary - 5 to 14'
      it_behaves_like 'course age group row', 'Primary', '7_to_11', 'Primary - 7 to 11'
      it_behaves_like 'course age group row', 'Primary', '7_to_14', 'Primary - 7 to 14'
    end

    context 'when course is secondary' do
      it_behaves_like 'course age group row', 'Secondary', '5_to_18', 'Secondary - 5 to 18'
      it_behaves_like 'course age group row', 'Secondary', '7_to_14', 'Secondary - 7 to 14'
      it_behaves_like 'course age group row', 'Secondary', '9_to_16', 'Secondary - 9 to 16'
      it_behaves_like 'course age group row', 'Secondary', '11_to_16', 'Secondary - 11 to 16'
      it_behaves_like 'course age group row', 'Secondary', '11_to_18', 'Secondary - 11 to 18'
      it_behaves_like 'course age group row', 'Secondary', '11_to_19', 'Secondary - 11 to 19'
      it_behaves_like 'course age group row', 'Secondary', '13_to_18', 'Secondary - 13 to 18'
      it_behaves_like 'course age group row', 'Secondary', '14_to_18', 'Secondary - 14 to 18'
      it_behaves_like 'course age group row', 'Secondary', '14_to_19', 'Secondary - 14 to 19'
    end

    context 'when course is further education' do
      let(:course) { create(:course, :further_education, age_range_in_years: nil) }

      it 'does not include age group row' do
        expect(summary_card_content).not_to include('Age group')
      end
    end
  end

  shared_examples 'course qualification row' do |course_qualification, expected_output|
    let(:course) { create(:course, qualification: course_qualification) }

    before { allow(course).to receive(:available_placements_count).and_return(2) }

    it "returns the correct qualification row for #{course_qualification}" do
      expect(summary_card_content).to include("Qualification awarded#{expected_output}")
    end
  end

  describe 'when displaying qualification' do
    it_behaves_like 'course qualification row', :qts, 'QTS only'
    it_behaves_like 'course qualification row', :pgce_with_qts, 'QTS with PGCE'
    it_behaves_like 'course qualification row', :pgde_with_qts, 'QTS with PGDE'
    it_behaves_like 'course qualification row', :pgce, 'PGCE without QTS'
    it_behaves_like 'course qualification row', :pgde, 'PGDE without QTS'
    it_behaves_like 'course qualification row', :undergraduate_degree_with_qts, 'Teacher degree apprenticeship with QTS'
  end

  shared_examples 'course degree requirements row' do |course_degree_type, course_degree_grade_required, expected_output|
    let(:course) { create(:course, degree_type:, degree_grade:) }
    let(:degree_type) { course_degree_type }
    let(:degree_grade) { course_degree_grade_required }

    before { allow(course).to receive(:available_placements_count).and_return(2) }

    it "returns the correct degree requirements row for #{course_degree_type} and #{course_degree_grade_required}" do
      expect(summary_card_content).to include("Degree required #{expected_output}")
    end
  end

  describe 'when displaying course degree requirements' do
    context 'when course requires 2:1 degree' do
      it_behaves_like 'course degree requirements row', :postgraduate, 'two_one', '2:1 bachelor’s degree or above or equivalent qualification'
    end

    context 'when course requires 2:2 degree' do
      it_behaves_like 'course degree requirements row', :postgraduate, 'two_two', '2:2 bachelor’s degree or above or equivalent qualification'
    end

    context 'when course requires third class degree' do
      it_behaves_like 'course degree requirements row',
                      :postgraduate,
                      'third_class',
                      'Bachelor’s degree or equivalent qualification This should be an honours degree (Third or above), or equivalent'
    end

    context 'when course requires "Pass" degree' do
      it_behaves_like 'course degree requirements row', :postgraduate, 'not_required', 'Bachelor’s degree or equivalent qualification'
    end

    context 'when course requires no degree' do
      it_behaves_like 'course degree requirements row', :undergraduate, 'not_required', 'No degree required'

      it 'does not render the hint text' do
        course = create(:course, degree_type: 'undergraduate', degree_grade: 'not_required')
        expect(render_inline(described_class.new(course:))).not_to include('or equivalent qualification')
      end
    end
  end

  shared_examples 'visa sponsorship row' do |funding, visa_sponsorship, expected_text|
    let(:course) do
      create(
        :course,
        funding:,
        can_sponsor_student_visa:,
        can_sponsor_skilled_worker_visa:
      )
    end
    let(:can_sponsor_student_visa) { visa_sponsorship[:can_sponsor_student_visa] }
    let(:can_sponsor_skilled_worker_visa) { visa_sponsorship[:can_sponsor_skilled_worker_visa] }

    it "displays the correct visa sponsorship text for #{funding} courses with #{visa_sponsorship}" do
      expect(summary_card_content).to include("Visa sponsorship#{expected_text}")
    end
  end

  describe 'when displaying course visa sponsorship' do
    context 'when the provider sponsor skilled worker visa for a salaried course' do
      it_behaves_like 'visa sponsorship row', :salary, { can_sponsor_skilled_worker_visa: true }, 'Skilled Worker visas can be sponsored'
      it_behaves_like 'visa sponsorship row', :apprenticeship, { can_sponsor_skilled_worker_visa: true }, 'Skilled Worker visas can be sponsored'
    end

    context 'when the provider sponsor skilled worker visa sponsorship for an unsalaried course' do
      it_behaves_like 'visa sponsorship row', :fee, { can_sponsor_skilled_worker_visa: true }, 'Visas cannot be sponsored'
    end

    context 'when the provider specifies student visa sponsorship for an salaried course' do
      it_behaves_like 'visa sponsorship row', :salary, { can_sponsor_student_visa: true }, 'Visas cannot be sponsored'
      it_behaves_like 'visa sponsorship row', :apprenticeship, { can_sponsor_student_visa: true }, 'Visas cannot be sponsored'
    end

    context 'when the provider specifies student visa sponsorship for an unsalaried course' do
      it_behaves_like 'visa sponsorship row', :fee, { can_sponsor_student_visa: true }, 'Student visas can be sponsored'
    end

    context 'when neither kind of visa is sponsored' do
      it_behaves_like 'visa sponsorship row', :fee, { can_sponsor_student_visa: false }, 'Visas cannot be sponsored'
      it_behaves_like 'visa sponsorship row', :salary, { can_sponsor_student_visa: false }, 'Visas cannot be sponsored'
      it_behaves_like 'visa sponsorship row', :apprenticeship, { can_sponsor_student_visa: false }, 'Visas cannot be sponsored'
    end
  end
end
