# frozen_string_literal: true

require 'rails_helper'

describe CourseDecorator do
  let(:current_recruitment_cycle) { build_stubbed(:recruitment_cycle) }
  let(:next_recruitment_cycle) { build_stubbed(:recruitment_cycle, :next) }
  let(:provider) { build_stubbed(:provider, recruitment_cycle: current_recruitment_cycle) }
  let(:english) { build_stubbed(:secondary_subject, :english) }
  let(:biology) { build_stubbed(:secondary_subject, :biology) }
  let(:mathematics) { build_stubbed(:secondary_subject, :mathematics) }
  let(:subjects) { [english, mathematics] }
  let(:has_vacancies) { false }
  let(:is_withdrawn) { false }

  let(:content_status) do
    is_withdrawn ? 'withdrawn' : ''
  end

  let(:course_enrichment) do
    build_stubbed(
      :course_enrichment,
      course_length: 'OneYear'
    )
  end

  let(:course) do
    build_stubbed(
      :course,
      :fee_type_based,
      level: 'Secondary',
      course_code: 'A1',
      name: 'Mathematics',
      qualification: 'pgce_with_qts',
      study_mode: 'full_time',
      start_date:,
      site_statuses: [site_status],
      provider:,
      accrediting_provider: provider,
      subjects:,
      enrichments: [course_enrichment],
      funding_type: 'fee'
    )
  end

  let(:start_date) { Time.zone.local(current_recruitment_cycle.year) }
  let(:site) { build_stubbed(:site) }
  let(:site_status) do
    build_stubbed(:site_status, :full_time_vacancies, site:)
  end

  let(:decorated_course) { course.decorate }

  it 'returns the course name and code in brackets' do
    expect(decorated_course.name_and_code).to eq('Mathematics (A1)')
  end

  it 'returns a list of subjects in alphabetical order' do
    expect(decorated_course.sorted_subjects).to eq('English<br>Mathematics')
  end

  it 'returns if applications are open or closed' do
    allow(course).to receive(:open_for_applications?).and_return(true)

    expect(decorated_course.open_or_closed_for_applications).to eq('Open')
  end

  it 'returns if course is an apprenticeship' do
    expect(decorated_course.apprenticeship?).to be(false)
  end

  it 'returns if course is SEND?' do
    expect(decorated_course.is_send?).to eq('No')
  end

  # it "returns the Find URL" do
  #   expect(decorated_course.find_url).to eq("#{Settings.search_ui.base_url}/course/#{provider.provider_code}/#{course.course_code}")
  # end

  it 'returns course length' do
    allow(course.enrichments).to receive(:most_recent).and_return([course_enrichment])

    expect(decorated_course.length).to eq('1 year')
  end

  context 'recruitment cycles' do
    before do
      allow(Settings).to receive(:current_recruitment_cycle_year).and_return(2019)
    end

    context 'for a course in the current cycle' do
      it 'knows which cycle it’s in' do
        expect(decorated_course.next_cycle?).to be(false)
        expect(decorated_course.current_cycle?).to be(true)
      end
    end

    context 'for a course in the next cycle' do
      let(:provider) { build_stubbed(:provider, recruitment_cycle: next_recruitment_cycle) }

      it 'knows which cycle it’s in' do
        expect(decorated_course.next_cycle?).to be(true)
        expect(decorated_course.current_cycle?).to be(false)
      end
    end
  end

  # context "status tag" do
  #   let(:status_tag) { course.decorate.status_tag }

  #   context "A non running course" do
  #     let(:course) { build_stubbed(:course, ucas_status: "not_running") }

  #     it "Returns red tag" do
  #       expect(status_tag).to include("govuk-tag--red")
  #     end

  #     it "Returns text withdrawn" do
  #       expect(status_tag).to include("Withdrawn")
  #     end
  #   end

  #   context "An empty course" do
  #     let(:course) { build_stubbed(:course, content_status: "empty") }

  #     it "Returns grey tag" do
  #       expect(status_tag).to include("govuk-tag--grey")
  #     end

  #     it "Returns text empty" do
  #       expect(status_tag).to include("Empty")
  #     end
  #   end

  #   context "A draft course" do
  #     let(:course) { build_stubbed(:course, content_status: "draft") }

  #     it "Returns yellow tag" do
  #       expect(status_tag).to include("govuk-tag--yellow")
  #     end

  #     it "Returns text draft" do
  #       expect(status_tag).to include("Draft")
  #     end
  #   end

  #   context "A published with unpublished changes course" do
  #     let(:course) { build_stubbed(:course, content_status: "published_with_unpublished_changes") }

  #     it "Returns green tag" do
  #       expect(status_tag).to include("govuk-tag--green")
  #     end

  #     it "Returns text published*" do
  #       expect(status_tag).to include("Published&nbsp;*")
  #     end

  #     it "Returns unpublished status hint" do
  #       expect(status_tag).to include("*&nbsp;Unpublished&nbsp;changes")
  #     end
  #   end

  #   context "A rolled over course" do
  #     let(:course) { build_stubbed(:course, content_status: "rolled_over") }

  #     it "Returns grey tag" do
  #       expect(status_tag).to include("govuk-tag--grey")
  #     end

  #     it "Returns text rolled over" do
  #       expect(status_tag).to include("Rolled over")
  #     end
  #   end

  #   context "A withdrawn course" do
  #     let(:course) { build_stubbed(:course, content_status: "withdrawn") }

  #     it "Returns red tag" do
  #       expect(status_tag).to include("govuk-tag--red")
  #     end

  #     it "Returns text withdrawn" do
  #       expect(status_tag).to include("Withdrawn")
  #     end
  #   end
  # end

  # describe "#selectable_subjects" do
  #   let(:course) do
  #     build_stubbed(
  #       :course,
  #       edit_options: {
  #         subjects: subjects.map do |subject|
  #           subject.to_jsonapi[:data]
  #         end,
  #       },
  #     )
  #   end

  #   it "gets the name and id" do
  #     expect(decorated_course.selectable_subjects).to eq([
  #       [english.subject_name, english.id],
  #       [mathematics.subject_name, mathematics.id],
  #     ])
  #   end
  # end

  # describe "#selected_subject_ids" do
  #   let(:selectable_subjects) { [english, mathematics] }
  #   let(:subjects) { [biology, mathematics] }

  #   let(:course) do
  #     build_stubbed(
  #       :course,
  #       subjects: subjects,
  #       edit_options: {
  #         subjects: subjects.map do |subject|
  #           subject.to_jsonapi[:data]
  #         end,
  #       },
  #     )
  #   end

  #   it "returns ids for only subjects that are selectable" do
  #     expect(decorated_course.selected_subject_ids).to match_array([biology.id, mathematics.id])
  #   end
  # end

  describe '#a_levels_requirements_answered?' do
    context 'when a_level_requirements is nil' do
      it 'returns false' do
        course.a_level_requirements = nil
        expect(decorated_course.a_levels_requirements_answered?).to be false
      end
    end

    context 'when a_level_requirements is true' do
      it 'returns true' do
        course.a_level_requirements = true
        expect(decorated_course.a_levels_requirements_answered?).to be true
      end
    end

    context 'when a_level_requirements is false' do
      it 'returns true' do
        course.a_level_requirements = false
        expect(decorated_course.a_levels_requirements_answered?).to be true
      end
    end
  end

  describe '#subject_present?' do
    it 'returns true when the subject id exists' do
      expect(decorated_course.subject_present?(english)).to be(true)
    end

    it 'returns true when the subject id does not exists' do
      expect(decorated_course.subject_present?(biology)).to be(false)
    end
  end

  describe '#chosen_subjects' do
    context 'when physics is the main subject' do
      let(:physics) { build_stubbed(:secondary_subject, :physics, id: 29) }
      let(:chemistry) { build_stubbed(:secondary_subject, :chemistry, id: 12) }
      let(:subjects) { [physics, chemistry] }
      let(:course) do
        build_stubbed(
          :course,
          name: 'Physics',
          subjects:,
          master_subject_id: 29
        )
      end

      let(:decorated_course) { course.decorate }

      it 'displays physics above the second subject chosen' do
        expect(decorated_course.chosen_subjects).to eq('Physics<br>Chemistry')
      end
    end

    context 'when modern languages only is chosen' do
      let(:french) { build_stubbed(:modern_languages_subject, :french) }
      let(:german) { build_stubbed(:modern_languages_subject, :german) }
      let(:subjects) { [french, german] }
      let(:course) do
        build_stubbed(
          :course,
          name: 'Modern languages',
          subjects:,
          master_subject_id: 33
        )
      end

      let(:decorated_course) { course.decorate }

      it 'displays modern languages before the modern languages subjects' do
        expect(decorated_course.chosen_subjects).to eq('Modern Languages<br>French<br>German')
      end
    end

    context 'when physics is chosen as the main subject and modern languages as the second' do
      let(:modern_languages) { build_stubbed(:secondary_subject, :modern_languages) }
      let(:french) { build_stubbed(:modern_languages_subject, :french) }
      let(:german) { build_stubbed(:modern_languages_subject, :german) }
      let(:subjects) { [modern_languages, french, german] }
      let(:course) do
        build_stubbed(
          :course,
          name: 'Physics',
          subjects:,
          master_subject_id: 29
        )
      end

      let(:decorated_course) { course.decorate }

      it 'displays physics before the modern languages subjects' do
        expect(decorated_course.chosen_subjects).to eq('Physics<br>Modern Languages<br>French<br>German')
      end
    end

    context 'when modern languages is chosen as the main subject and latin as the second' do
      let(:french) { build_stubbed(:modern_languages_subject, :french) }
      let(:german) { build_stubbed(:modern_languages_subject, :german) }
      let(:latin) { build_stubbed(:secondary_subject, :latin) }
      let(:subjects) { [french, german, latin] }
      let(:course) do
        build_stubbed(
          :course,
          name: 'Modern languages',
          subjects:,
          master_subject_id: 33
        )
      end

      let(:decorated_course) { course.decorate }

      it 'displays modern languages and the specific languages before the latin subject' do
        expect(decorated_course.chosen_subjects).to eq('Modern Languages<br>French<br>German<br>Latin')
      end
    end
  end

  # context "financial incentives" do
  #   describe "#salaried?" do
  #     let(:subject) { decorated_course }

  #     context "course is salaried" do
  #       let(:course) { build_stubbed :course, funding_type: "salary" }

  #       it { is_expected.to be_salaried }
  #     end

  #     context "course is an apprenticeship with salary" do
  #       let(:course) { build_stubbed :course, funding_type: "apprenticeship" }

  #       it { is_expected.to be_salaried }
  #     end

  #     context "course is not salaried" do
  #       let(:course) { build_stubbed :course, :with_fees }

  #       it { is_expected.to_not be_salaried }
  #     end
  #   end

  #   describe "#funding_option" do
  #     let(:subject) { decorated_course.funding_option }

  #     context "Salary" do
  #       let(:course) { build_stubbed :course, funding_type: "salary" }

  #       it { is_expected.to eq("Salary") }
  #     end

  #     context "Apprenticeship" do
  #       let(:course) { build_stubbed :course, funding_type: "apprenticeship" }

  #       it { is_expected.to eq("Salary") }
  #     end

  #     context "Bursary and Scholarship" do
  #       let(:mathematics) { build_stubbed(:subject, :mathematics, scholarship: "2000", bursary_amount: "3000") }
  #       let(:course) { build_stubbed :course, subjects: [mathematics] }

  #       it { is_expected.to eq("Scholarships or bursaries, as well as student finance, are available if youre eligible") }
  #     end

  #     context "Bursary" do
  #       let(:mathematics) { build_stubbed(:subject, :mathematics, bursary_amount: "3000") }
  #       let(:course) { build_stubbed :course, subjects: [mathematics] }

  #       it { is_expected.to eq("Bursaries and student finance are available if youre eligible") }
  #     end

  #     context "Student finance" do
  #       let(:course) { build_stubbed :course }

  #       it { is_expected.to eq("Student finance if youre eligible") }
  #     end

  #     context "Courses excluded from bursaries" do
  #       let(:pe) { build_stubbed(:subject) }
  #       let(:english) { build_stubbed(:subject, :english, bursary_amount: "3000") }

  #       let(:course) { build_stubbed :course, name: "Drama with English", subjects: [pe, english] }

  #       it { is_expected.to eq("Student finance if youre eligible") }
  #     end
  #   end

  describe '#subject_name' do
    context 'course has more than one subject' do
      it 'returns the course name' do
        expect(decorated_course.subject_name).to eq('Mathematics')
      end
    end

    context 'course has one subject' do
      let(:course_subject) { find_or_create :secondary_subject, :computing }
      let(:course) { build_stubbed(:course, subjects: [course_subject]) }

      it 'return the subject name' do
        expect(decorated_course.subject_name).to eq('Computing')
      end
    end
  end

  describe '#computed_subject_name_or_names' do
    context 'course has more than one subject' do
      it "returns both subjects names seperated by a 'with'" do
        expect(decorated_course.computed_subject_name_or_names).to eq('English with mathematics')
      end
    end

    context 'course has one subject' do
      let(:course_subject) { find_or_create :secondary_subject, :computing }
      let(:course) { build_stubbed(:course, subjects: [course_subject]) }

      it 'return the subject name' do
        expect(decorated_course.computed_subject_name_or_names).to eq('computing')
      end
    end

    context 'course has a language subject' do
      let(:course_subject) { find_or_create :secondary_subject, :english }
      let(:course) { build(:course, subjects: [course_subject]) }

      it 'return the capitalised subject name' do
        expect(decorated_course.computed_subject_name_or_names).to eq('English')
      end
    end

    context 'course is modern languages' do
      let(:course_subject) { find_or_create :secondary_subject, :modern_languages }
      let(:course) { build(:course, subjects: [course_subject, build(:modern_languages_subject, :french)]) }

      it 'return lowercase modern languages and capitalised language' do
        expect(decorated_course.computed_subject_name_or_names).to eq('modern languages with French')
      end
    end

    context 'course is modern languages (other)' do
      let(:course_subject) { find_or_create :secondary_subject, :modern_languages }
      let(:course) { build(:course, subjects: [course_subject, build(:modern_languages_subject, :modern_languages_other)]) }

      it 'returns one modern languages' do
        expect(decorated_course.computed_subject_name_or_names).to eq('modern languages')
      end
    end
  end

  describe '#bursary_requirements' do
    subject { decorated_course.bursary_requirements }

    context 'Course with mathematics as a subject' do
      let(:mathematics) { build_stubbed(:secondary_subject, :mathematics, subject_name: 'Primary with Mathematics') }
      let(:english) { build_stubbed(:secondary_subject, :english) }
      let(:subjects) { [mathematics, english] }

      expected_requirements = [
        'a degree of 2:2 or above in any subject',
        'at least grade B in maths A-level (or an equivalent)'
      ]

      it { is_expected.to eq(expected_requirements) }
    end

    context 'Course without mathematics as a subject' do
      let(:english) { build_stubbed(:secondary_subject, :english) }
      let(:subjects) { [biology, english] }

      expected_requirements = [
        'a degree of 2:2 or above in any subject'
      ]

      it { is_expected.to eq(expected_requirements) }
    end
  end

  #   describe "#bursary_first_line_ending" do
  #     let(:subject) { decorated_course.bursary_first_line_ending }

  #     context "More than one requirement" do
  #       let(:mathematics) { build_stubbed :subject, :mathematics, subject_name: "Primary with Mathematics" }
  #       let(:english) { build_stubbed :subject, :english }
  #       let(:subjects) { [mathematics, english] }

  #       expected_line_ending = ":"

  #       it { is_expected.to eq(expected_line_ending) }
  #     end

  #     context "Course without mathematics as a subject" do
  #       let(:english) { build_stubbed :subject, :english }
  #       let(:subjects) { [biology, english] }

  #       expected_line_ending = "a degree of 2:2 or above in any subject."

  #       it { is_expected.to eq(expected_line_ending) }
  #     end
  #   end

  #   describe "#bursary_only" do
  #     let(:subject) { decorated_course }

  #     context "course only has bursary financial incentives" do
  #       let(:mathematics) { build_stubbed :subject, bursary_amount: "2000" }
  #       let(:english) { build_stubbed :subject, bursary_amount: "4000" }
  #       let(:subjects) { [mathematics, english] }

  #       it { is_expected.to be_bursary_only }
  #     end

  #     context "course has other financial incentives apart from bursaries" do
  #       let(:mathematics) { build_stubbed :subject, bursary_amount: "2000" }
  #       let(:english) { build_stubbed :subject, scholarship: "4000" }
  #       let(:subjects) { [mathematics, english] }

  #       it { is_expected.to_not be_bursary_only }
  #     end
  #   end

  #   describe "#has_bursary" do
  #     context "course has no bursary" do
  #       it "returns false" do
  #         expect(decorated_course.has_bursary?).to eq(false)
  #       end
  #     end

  #     context "course has bursary" do
  #       let(:mathematics) { build_stubbed :subject, bursary_amount: "2000" }
  #       let(:english) { build_stubbed :subject, bursary_amount: "4000" }
  #       let(:subjects) { [biology, mathematics, english] }

  #       it "returns true" do
  #         expect(decorated_course.has_bursary?).to eq(true)
  #       end
  #     end
  #   end

  describe '#bursary_amount' do
    context 'course has bursary' do
      let(:mathematics) { build(:secondary_subject, bursary_amount: '2000') }
      let(:english) { build(:secondary_subject, bursary_amount: '4000') }
      let(:subjects) { [mathematics, english] }

      let(:course) { build(:course, :secondary, subjects:) }

      it 'returns the maximum bursary amount' do
        expect(decorated_course.bursary_amount).to eq('4000')
      end
    end
  end

  describe '#excluded_from_bursary?' do
    subject { decorated_course }

    before do
      allow(course).to receive(:subjects).and_return(subjects)
    end

    context 'course name does not qualify for exclusion' do
      let(:course) { build_stubbed(:course, name: 'Mathematics') }

      it { is_expected.not_to be_excluded_from_bursary }
    end

    context "course name contains 'with'" do
      context 'Drama' do
        let(:english) { build_stubbed(:secondary_subject, bursary_amount: '30000') }
        let(:drama) { build_stubbed(:secondary_subject, subject_name: 'Drama') }
        let(:subjects) { [english, drama] }

        context 'Drama with English' do
          let(:course) { build_stubbed(:course, name: 'Drama with English', subjects:) }

          it { is_expected.to be_excluded_from_bursary }
        end

        context 'English with Drama' do
          let(:course) { build_stubbed(:course, name: 'English with Drama', subjects:) }

          it { is_expected.not_to be_excluded_from_bursary }
        end
      end

      context 'PE' do
        let(:english) { build_stubbed(:secondary_subject, bursary_amount: '30000') }
        let(:pe) { build_stubbed(:secondary_subject, subject_name: 'PE') }
        let(:subjects) { [english, pe] }

        context 'PE with English' do
          let(:course) { build_stubbed(:course, name: 'PE with English', subjects:) }

          it { is_expected.to be_excluded_from_bursary }
        end

        context 'English with PE' do
          let(:course) { build_stubbed(:course, name: 'English with PE', subjects:) }

          it { is_expected.not_to be_excluded_from_bursary }
        end
      end

      context 'Physical Education' do
        let(:english) { build_stubbed(:secondary_subject, bursary_amount: '30000') }
        let(:physical_education) { build_stubbed(:secondary_subject, subject_name: 'Physical Education') }
        let(:subjects) { [english, physical_education] }

        context 'Physical Education with English' do
          let(:course) { build_stubbed(:course, name: 'Physical Education with English', subjects:) }

          it { is_expected.to be_excluded_from_bursary }
        end

        context 'English with Physical Education' do
          let(:course) { build_stubbed(:course, name: 'English with Physical Education', subjects:) }

          it { is_expected.not_to be_excluded_from_bursary }
        end
      end

      context 'Media Studies' do
        let(:english) { build_stubbed(:secondary_subject, bursary_amount: '30000') }
        let(:media_studies) { build_stubbed(:secondary_subject, subject_name: 'Media Studies') }
        let(:subjects) { [english, media_studies] }

        context 'Media Studies with English' do
          let(:course) { build_stubbed(:course, name: 'Media Studies with English', subjects:) }

          it { is_expected.to be_excluded_from_bursary }
        end

        context 'English with Media Studies' do
          let(:course) { build_stubbed(:course, name: 'English with Media Studies', subjects:) }

          it { is_expected.not_to be_excluded_from_bursary }
        end
      end
    end

    context "course name contains 'and'" do
      let(:english) { build_stubbed(:secondary_subject, bursary_amount: '30000') }
      let(:drama) { build_stubbed(:secondary_subject, subject_name: 'Drama') }
      let(:subjects) { [english, drama] }

      context 'Drama and English' do
        let(:course) { build_stubbed(:course, name: 'Drama and English', subjects:) }

        it { is_expected.not_to be_excluded_from_bursary }
      end

      context 'English and Drama' do
        let(:course) { build_stubbed(:course, name: 'English and Drama', subjects:) }

        it { is_expected.not_to be_excluded_from_bursary }
      end
    end
  end

  describe '#scholarship_amount' do
    context 'course has scholarship' do
      let(:mathematics) { build(:secondary_subject, scholarship: '2000') }
      let(:english) { build(:secondary_subject, scholarship: '4000') }
      let(:subjects) { [mathematics, english] }

      let(:course) { build(:course, :secondary, subjects:) }

      it 'returns the maximum scholarship amount' do
        expect(decorated_course.scholarship_amount).to eq('4000')
      end
    end
  end

  #   context "#has_scholarship?" do
  #     context "course has no scholarship" do
  #       it "returns false" do
  #         expect(decorated_course.has_scholarship?).to eq(false)
  #       end
  #     end

  #     context "course has scholarship" do
  #       let(:mathematics) { build_stubbed :subject, scholarship: "6000" }
  #       let(:english) { build_stubbed :subject, scholarship: "8000" }
  #       let(:subjects) { [biology, mathematics, english] }

  #       it "returns true" do
  #         expect(decorated_course.has_scholarship?).to eq(true)
  #       end
  #     end
  #   end

  #   context "early careers payment option" do
  #     context "course has no early career payment option" do
  #       it "returns false" do
  #         expect(decorated_course.has_early_career_payments?).to eq(false)
  #       end
  #     end

  #     context "course has early career payment option" do
  #       let(:english) { build_stubbed :subject, early_career_payments: "2000" }
  #       let(:subjects) { [biology, mathematics, english] }

  #       it "returns true" do
  #         expect(decorated_course.has_early_career_payments?).to eq(true)
  #       end
  #     end
  #   end
  # end

  describe '#other_course_length?' do
    before do
      allow(course.enrichments).to receive(:most_recent).and_return([course_enrichment])
    end

    context 'when course_length is a pre-defined value' do
      let(:course_enrichment) { build_stubbed(:course_enrichment, course_length: 'OneYear') }

      it 'returns false' do
        expect(decorated_course.other_course_length?).to be_falsey
      end
    end

    context 'when course_length is nil' do
      let(:course_enrichment) { build_stubbed(:course_enrichment, course_length: nil) }

      it 'returns false so there is no default value' do
        expect(decorated_course.other_course_length?).to be_falsey
      end
    end

    context 'when course_length is user set' do
      let(:course_enrichment) { build_stubbed(:course_enrichment, course_length: '3 months') }

      it 'returns true' do
        expect(decorated_course.other_course_length?).to be_truthy
      end
    end
  end

  describe '#subject_page_title' do
    let(:subject_page_title) { course.decorate.subject_page_title }

    context 'a primary course' do
      let(:course) { build_stubbed(:course, level: 'primary') }

      it 'returns the correct page title' do
        expect(subject_page_title).to eq('Subject')
      end
    end

    context 'a secondary course' do
      let(:course) { build_stubbed(:course, level: 'secondary') }

      it 'returns the correct page title' do
        expect(subject_page_title).to eq('Subject')
      end
    end

    context 'a further education course' do
      let(:course) { build_stubbed(:course, level: 'further_education') }

      it 'returns the correct page title' do
        expect(subject_page_title).to eq('Pick a subject')
      end
    end
  end

  describe '#description' do
    subject(:description) { course.decorate.description }

    context 'when PGCE with QTS' do
      let(:course) { build_stubbed(:course, qualification: 'pgce_with_qts') }

      it 'returns the correct page title' do
        expect(description).to eq('QTS with PGCE full time teaching apprenticeship')
      end
    end

    context 'when PGDE with QTS' do
      let(:course) { build_stubbed(:course, qualification: 'pgde_with_qts') }

      it 'returns the correct page title' do
        expect(description).to eq(course.description)
      end
    end
  end

  describe '#cycle_range' do
    subject { course.decorate.cycle_range }

    let(:expected_cycle_range) do
      "#{current_recruitment_cycle.year} to #{current_recruitment_cycle.year.to_i + 1}"
    end

    it 'states the correct cycle range' do
      expect(subject).to eq(expected_cycle_range)
    end
  end

  # describe "#use_financial_support_placeholder?" do
  #   before do
  #     allow(Settings).to receive(:financial_support_placeholder_cycle)
  #       .and_return(financial_support_placeholder_cycle)
  #   end

  #   subject { course.decorate.use_financial_support_placeholder? }
  #   context "financial_support_placeholder_cycle is nil" do
  #     let(:financial_support_placeholder_cycle) { nil }

  #     it "should be false" do
  #       expect(subject).to be_falsey
  #     end
  #   end
  #   context "financial_support_placeholder_cycle not the same as course recruitment_cycle_year" do
  #     let(:financial_support_placeholder_cycle) do
  #       course.recruitment_cycle_year.to_i + 1
  #     end
  #     it "should be false" do
  #       expect(subject).to be_falsey
  #     end
  #   end

  #   context "financial_support_placeholder_cycle same as course recruitment_cycle_year" do
  #     let(:financial_support_placeholder_cycle) do
  #       course.recruitment_cycle_year.to_i
  #     end
  #     it "should be true" do
  #       expect(subject).to be_truthy
  #     end
  #   end
  # end

  describe '#cannot_change_funding_type?' do
    context 'when course is published' do
      before { allow(course).to receive(:is_published?).and_return(true) }

      it 'returns true' do
        expect(decorated_course.cannot_change_funding_type?).to be true
      end
    end

    context 'when course is withdrawn' do
      before { allow(course).to receive(:is_withdrawn?).and_return(true) }

      it 'returns true' do
        expect(decorated_course.cannot_change_funding_type?).to be true
      end
    end

    context 'when teacher degree apprenticeship' do
      before { allow(course).to receive(:teacher_degree_apprenticeship?).and_return(true) }

      it 'returns true' do
        expect(decorated_course.cannot_change_funding_type?).to be true
      end
    end

    context 'none of the conditions are met' do
      before do
        allow(course).to receive_messages(is_published?: false, is_withdrawn?: false, teacher_degree_apprenticeship?: false)
      end

      it 'returns false' do
        expect(decorated_course.cannot_change_funding_type?).to be false
      end
    end
  end

  describe '#cannot_change_study_mode?' do
    context 'when course is withdrawn' do
      before { allow(course).to receive(:is_withdrawn?).and_return(true) }

      it 'returns true' do
        expect(decorated_course.cannot_change_study_mode?).to be true
      end
    end

    context 'when course is teacher degree apprenticeship' do
      before { allow(course).to receive(:teacher_degree_apprenticeship?).and_return(true) }

      it 'returns true' do
        expect(decorated_course.cannot_change_study_mode?).to be true
      end
    end

    context 'when none of the conditions are met' do
      before do
        allow(course).to receive_messages(is_withdrawn?: false, teacher_degree_apprenticeship?: false)
      end

      it 'returns false' do
        expect(decorated_course.cannot_change_study_mode?).to be false
      end
    end
  end

  describe '#cannot_change_skilled_worker_visa?' do
    context 'when withdrawn' do
      before { allow(course).to receive(:is_withdrawn?).and_return(true) }

      it 'returns true' do
        expect(decorated_course.cannot_change_skilled_worker_visa?).to be true
      end
    end

    context 'when course is teacher degree apprenticeship' do
      before { allow(course).to receive(:teacher_degree_apprenticeship?).and_return(true) }

      it 'returns true' do
        expect(decorated_course.cannot_change_skilled_worker_visa?).to be true
      end
    end

    context 'when none of the conditions are met' do
      before { allow(course).to receive(:teacher_degree_apprenticeship?).and_return(true) }

      it 'returns false' do
        expect(decorated_course.cannot_change_skilled_worker_visa?).to be true
      end
    end
  end

  describe '#show_skilled_worker_visa_row?' do
    context 'when course is a school direct salaried training programme' do
      before { allow(course).to receive(:school_direct_salaried_training_programme?).and_return(true) }

      it 'returns true' do
        expect(decorated_course.show_skilled_worker_visa_row?).to be true
      end
    end

    context 'when course is a pg teaching apprenticeship' do
      before { allow(course).to receive(:pg_teaching_apprenticeship?).and_return(true) }

      it 'returns true' do
        expect(decorated_course.show_skilled_worker_visa_row?).to be true
      end
    end

    context 'when course is a teacher degree apprenticeship' do
      before { allow(course).to receive(:teacher_degree_apprenticeship?).and_return(true) }

      it 'returns true' do
        expect(decorated_course.show_skilled_worker_visa_row?).to be true
      end
    end

    context 'when none of the conditions are met' do
      before do
        allow(course).to receive_messages(school_direct_salaried_training_programme?: false, pg_teaching_apprenticeship?: false, teacher_degree_apprenticeship?: false)
      end

      it 'returns false' do
        expect(decorated_course.show_skilled_worker_visa_row?).to be false
      end
    end
  end

  describe '#financial_incentive_details' do
    subject { course.decorate.financial_incentive_details }

    context 'bursaries and scholarships is announced' do
      before do
        FeatureFlag.activate(:bursaries_and_scholarships_announced)
      end

      context 'course has no financial incentive' do
        it "returns the correct details under 'financial_incentive_details'" do
          expect(subject).to eq('None available')
        end
      end

      context 'course has financial incentive' do
        before do
          allow(course).to receive(:financial_incentives).and_return([financial_incentive])
        end

        context 'course has both bursary and scholarship available' do
          let(:financial_incentive) { build_stubbed(:financial_incentive, scholarship: '2000', bursary_amount: '3000') }

          it "returns the correct details under 'financial_incentive_details'" do
            expect(subject).to eq('Scholarships of £2,000 and bursaries of £3,000 are available')
          end
        end

        context 'course only has bursary available' do
          let(:financial_incentive) { build_stubbed(:financial_incentive, bursary_amount: '3000') }

          it "returns the correct details under 'financial_incentive_details'" do
            expect(subject).to eq('Bursaries of £3,000 available')
          end
        end
      end

      context 'course is in the next cycle' do
        before do
          allow(course).to receive(:recruitment_cycle_year).and_return(current_recruitment_cycle.year.to_i + 1)
        end

        it "returns the correct details under 'financial_incentive_details'" do
          expect(subject).to eq('Information not yet available')
        end
      end
    end

    context 'bursaries and scholarships is not announced' do
      it "returns the correct details under 'financial_incentive_details'" do
        expect(subject).to eq('Information not yet available')
      end
    end
  end
end
