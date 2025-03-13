# frozen_string_literal: true

require 'rails_helper'

describe Course do
  subject { course }

  let(:recruitment_cycle) { course.recruitment_cycle }
  let(:french) { find_or_create(:modern_languages_subject, :french) }
  let!(:financial_incentive) { create(:financial_incentive, subject: modern_languages) }
  let(:modern_languages) { find_or_create(:secondary_subject, :modern_languages) }
  let(:course) do
    create(
      :course,
      level: 'secondary',
      name: 'Biology',
      course_code: '3X9F',
      subjects: [find_or_create(:secondary_subject, :biology)]
    )
  end

  its(:to_s) { is_expected.to eq("Biology (#{course.provider.provider_code}/3X9F) [#{course.recruitment_cycle}]") }
  its(:modular) { is_expected.to eq('') }

  it { is_expected.to delegate_method(:provider_name).to(:provider).allow_nil }
  it { is_expected.to delegate_method(:provider_code).to(:provider).allow_nil }

  describe '#name_and_code' do
    it 'returns the course name and code in brackets' do
      expect(course.name_and_code).to eq('Biology (3X9F)')
    end
  end

  describe '#campaign_name' do
    it 'assigns the campaign' do
      course.engineers_teach_physics!
      expect(course.campaign_name).to eq 'engineers_teach_physics'
      expect(course.engineers_teach_physics?).to be true
    end
  end

  describe 'auditing' do
    it { is_expected.to be_audited }
    it { is_expected.to have_associated_audits }
  end

  describe '#touch_provider' do
    let(:course) { create(:course) }

    it 'sets changed_at to the current time' do
      Timecop.freeze do
        course.touch
        expect(course.provider.changed_at).to be_within(1.second).of Time.now.utc
      end
    end

    it 'leaves updated_at unchanged' do
      timestamp = 1.hour.ago
      course.provider.update updated_at: timestamp
      course.touch
      expect(course.provider.updated_at).to be_within(1.second).of timestamp
    end
  end

  describe 'associations' do
    it { is_expected.to belong_to(:provider) }

    it do
      expect(subject).to belong_to(:accrediting_provider)
        .with_foreign_key(:accredited_provider_code)
        .with_primary_key(:provider_code)
        .optional
    end

    it { is_expected.to have_many(:subjects).through(:course_subjects) }
    it { is_expected.to have_many(:site_statuses) }
    it { is_expected.to have_many(:study_site_placements).dependent(:destroy) }
    it { is_expected.to have_many(:study_sites).through(:study_site_placements).source(:site) }
    it { is_expected.to have_many(:sites) }
    it { is_expected.to have_many(:enrichments) }
    it { is_expected.to have_many(:financial_incentives) }

    describe 'course_subjects' do
      context 'Adding subjects to a new course' do
        let(:primary_with_mathematics) { find_or_create(:primary_subject, :primary_with_mathematics) }
        let(:further_education) { find_or_create(:further_education_subject) }
        let(:english) { find_or_create(:secondary_subject, :english) }
        let(:maths) { find_or_create(:secondary_subject, :mathematics) }

        context 'Primary course' do
          let(:course) { build(:course, level: 'primary', subjects: []) }

          it 'Does not assign a position' do
            course.course_subjects.build(subject: primary_with_mathematics)

            expect(course.course_subjects.first.position).to be_nil
          end
        end

        context 'Further Education' do
          let(:course) { build(:course, level: 'further_education', subjects: []) }

          it 'Does not assign a position' do
            course.course_subjects.build(subject: further_education)

            expect(course.course_subjects.first.position).to be_nil
          end
        end

        context 'Secondary course' do
          let(:course) { build(:course, level: 'secondary', course_subjects: []) }

          # The Course factory adds subjects to the course
          # and I can't see how else to prevent the course having courses
          before { course.subjects.destroy_all }

          it 'Assigns position 0 to a single secondary subject' do
            course.course_subjects.build(subject: english)
            expect(course.course_subjects.first.position).to eq(0)
          end

          it 'Assigns position 0,1 to two secondary subjects in the order they are given' do
            course.course_subjects.build(subject: maths)
            course.course_subjects.build(subject: english)
            course_subjects = course.course_subjects

            expect(course_subjects[0].position).to eq(0)
            expect(course_subjects[1].position).to eq(1)
          end

          it 'Doesnt assign a position to languages' do
            course.course_subjects.build(subject: modern_languages)
            course.course_subjects.build(subject: french)

            expect(course.course_subjects[0].position).to eq(0)
            expect(course.course_subjects[1].position).to be_nil
          end
        end
      end

      context 'Adding subjects to an existing course' do
        let(:english) { find_or_create(:secondary_subject, :english) }
        let(:maths) { find_or_create(:secondary_subject, :mathematics) }

        context 'When the existing course has no priorities' do
          it 'Does not assign a priority to the new subject' do
            course = build(:course, level: 'secondary', subjects: [maths])
            course.course_subjects.first.position = nil

            course.subjects << english
            expect(course.course_subjects.map(&:position)).to eq([nil, nil])
          end
        end

        context 'When the existing course has a modern language subject with languages' do
          it 'Assigns the priority to the new secondary subject' do
            course = build(:course, level: 'secondary', subjects: [modern_languages, french])
            course.subjects << english

            expect(course.course_subjects.last.position).to eq(1)
          end
        end
      end

      it 'Orders course subjects by their position' do
        english = find_or_create(:secondary_subject, :english)
        maths = find_or_create(:secondary_subject, :mathematics)

        course = build(:course, level: 'secondary', subjects: [maths, english])
        course.save!
        course.reload

        subjects = course.subjects

        expect(subjects.first).to eq(maths)
        expect(subjects.second).to eq(english)
      end
    end

    describe '#modern_languages_subjects' do
      it 'gets modern language subjects' do
        course = create(:course, level: 'secondary', subjects: [modern_languages, french])
        expect(course.modern_languages_subjects).to contain_exactly(french)
      end
    end
  end

  describe '#find_a_level_subject_requirement!' do
    let(:course) { create(:course, a_level_subject_requirements:) }

    context 'when a requirement with the specified uuid exists' do
      let(:uuid) { 'valid_uuid' }
      let(:a_level_subject_requirements) { [{ uuid: 'valid_uuid', subject: 'Subject Requirement' }] }

      it 'returns the subject requirement' do
        expect(course.find_a_level_subject_requirement!(uuid)).to eq(a_level_subject_requirements.first.with_indifferent_access)
      end
    end

    context 'when no requirement with the specified uuid exists' do
      let(:uuid) { 'nonexistent_uuid' }
      let(:a_level_subject_requirements) { [] }

      it 'raises ActiveRecord::RecordNotFound' do
        expect { course.find_a_level_subject_requirement!(uuid) }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe '#applicable_for_engineers_teach_physics?' do
    subject { course.applicable_for_engineers_teach_physics? }

    context 'primary course' do
      let(:course) { build(:course, :primary) }

      it 'return false' do
        expect(subject).to be(false)
      end
    end

    context 'further education course' do
      let(:course) { build(:course, :further_education) }

      it 'return false' do
        expect(subject).to be(false)
      end
    end

    context 'secondary course' do
      context 'without physics' do
        let(:course) { build(:course, :secondary) }

        it 'return false' do
          expect(subject).to be(false)
        end
      end

      context 'with physics' do
        let(:physics) { find_or_create(:secondary_subject, :physics) }

        let(:course) { create(:course, :secondary, subjects: [physics]) }

        it 'return true' do
          expect(subject).to be(true)
        end

        context 'with another subject' do
          let(:maths) { find_or_create(:secondary_subject, :mathematics) }

          context 'on position 0' do
            let(:course) { create(:course, :secondary, subjects: [physics, maths]) }

            it 'return true' do
              expect(subject).to be(true)
            end
          end

          context 'on position 1' do
            let(:course) { create(:course, :secondary, subjects: [maths, physics]) }

            it 'return true' do
              expect(subject).to be(false)
            end
          end
        end
      end
    end
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:course_code) }
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:profpost_flag) }
    it { is_expected.to validate_presence_of(:program_type) }
    it { is_expected.to validate_presence_of(:qualification) }
    it { is_expected.to validate_presence_of(:start_date) }
    it { is_expected.to validate_presence_of(:study_mode) }
    it { is_expected.to validate_presence_of(:sites).on(:publish) }
    it { is_expected.to validate_presence_of(:subjects).on(:publish) }
    it { is_expected.to validate_presence_of(:level).on(:create) }

    it {
      expect(subject).to validate_presence_of(:level)
        .on(:publish)
        .with_message('^Select a subject level')
    }

    it 'validates scoped to provider_id and only on create and update' do
      expect(create(:course)).to validate_uniqueness_of(:course_code)
        .scoped_to(:provider_id)
        .on(%i[create update])
    end

    describe 'valid?' do
      context 'A new course' do
        let(:provider) { build(:provider) }
        let(:course) { described_class.new(provider:) }
        let(:errors) { course.errors.messages }

        before { course.valid?(:new) }

        it 'Requires a level' do
          error = errors[:level]
          expect(error).not_to be_empty
          expect(error.first).to include('Select a subject level')
        end

        it 'Requires a subject' do
          error = errors[:subjects]
          expect(error).not_to be_empty
          expect(error.first).to include('Select a subject')
        end

        context 'With modern languages as a subject' do
          let(:course) { described_class.new(provider:, subjects: [modern_languages]) }

          it 'Requires a language to be selected' do
            error = errors[:modern_languages_subjects]
            expect(error).not_to be_empty
            expect(error.first).to include('Select at least one language')
          end

          it 'Does not add an error if a language is selected' do
            course.subjects << french
            course.valid?(:new)
            error = course.errors.messages[:modern_languages_subjects]
            expect(error).to be_empty
          end
        end

        it 'Requires an age range' do
          error = errors[:age_range_in_years]
          expect(error).not_to be_empty
          expect(error.first).to include('Select an age range')
        end

        it 'Requires an outcome' do
          error = errors[:qualification]
          expect(error).not_to be_empty
          expect(error.first).to include('Select an outcome')
        end

        it 'Requires a program type to have been specified' do
          error = errors[:program_type]
          expect(error).not_to be_empty
          expect(error.first).to include('Select a funding type')
        end

        it 'Requires a study mode' do
          error = errors[:study_mode]
          expect(error).not_to be_empty
          expect(error.first).to include('Select a study mode')
        end

        context 'Applications open' do
          it 'Empty' do
            error = errors[:applications_open_from]
            expect(error).not_to be_empty
            expect(error.first).to include('Select an applications open date')
          end

          it 'A date outside of the current recruitment cycle' do
            course.applications_open_from = course.recruitment_cycle.application_start_date - 1
            course.valid?(:new)
            error = course.errors.messages[:applications_open_from]
            expect(error).not_to be_empty
            expect(error.first).to include("The date when applications open must be between #{recruitment_cycle.application_start_date.to_fs(:govuk_date)} and #{recruitment_cycle.application_end_date.to_fs(:govuk_date)}")
          end
        end

        it 'Requires at least one location' do
          error = errors[:sites]
          expect(error).not_to be_empty
          expect(error.first).to include('Select at least one school')
        end
      end

      context 'on publish' do
        let(:course) { create(:course, :without_validation, age_range_in_years: nil) }
        let(:errors) { course.errors.messages }

        before do
          course.applications_open_from = course.recruitment_cycle.application_start_date - 1
          course.valid?(:publish)
        end

        it 'requires age_range_in_years' do
          error = errors[:age_range_in_years]
          expect(error).not_to be_empty
          expect(error.first).to include('Select an age range')
        end

        it 'requires a applications_open_from date inside of the current recruitment cycle' do
          error = course.errors.messages[:applications_open_from]
          expect(error).not_to be_empty
          expect(error.first).to include("The date when applications open must be between #{recruitment_cycle.application_start_date.to_fs(:govuk_date)} and #{recruitment_cycle.application_end_date.to_fs(:govuk_date)}")
        end
      end

      context 'A further education course' do
        let(:course) { build(:course, level: 'further_education') }

        it 'Allows a blank options for age range in years' do
          course.age_range_in_years = nil
          expect(course.valid?).to be(true)
        end

        it 'Allows a blank option for english' do
          course.english = nil
          expect(course.valid?).to be(true)
        end

        it 'Allows a blank option for maths' do
          course.maths = nil
          expect(course.valid?).to be(true)
        end
      end

      context 'blank attribute' do
        subject do
          course.valid?
          course.errors.full_messages.first
        end

        let(:course) { build(:course, **blank_field) }

        context 'age_range_in_years' do
          let(:blank_field) { { age_range_in_years: nil } }

          it { is_expected.to include 'Select an age range' }
        end

        context 'maths' do
          let(:blank_field) { { maths: nil } }

          it { is_expected.to be_nil }
        end

        context 'english' do
          let(:blank_field) { { english: nil } }

          it { is_expected.to be_nil }
        end

        context 'science' do
          let(:blank_field) { { science: nil } }

          it { is_expected.to be_nil }
        end
      end

      context 'invalid_enrichment' do
        let(:course) { create(:course, enrichments: [invalid_enrichment]) }
        let(:invalid_enrichment) { build(:course_enrichment, about_course: '') }

        before do
          subject
          invalid_enrichment.about_course = Faker::Lorem.sentence(word_count: 1000)
          subject.valid?
        end

        it 'adds enrichment errors' do
          expect(subject.errors.full_messages).not_to be_empty
        end
      end
    end

    describe 'publishable?' do
      context 'invalid enrichment' do
        let(:course) { create(:course, enrichments: [invalid_enrichment]) }
        let(:invalid_enrichment) { create(:course_enrichment, about_course: '') }

        before do
          subject.publishable?
        end

        it 'adds enrichment errors' do
          expect(subject.errors.full_messages).not_to be_empty
        end
      end

      context 'invalid subjects' do
        let(:initial_draft_enrichment) { build(:course_enrichment, :published) }
        # This skips validations to ensure we don't have any legacy data that could be published
        let(:course) { create(:course, :skip_validate, level: :secondary, infer_subjects?: false, site_statuses: [create(:site_status, :new_status)], enrichments: [initial_draft_enrichment]) }

        before do
          subject.publishable?
        end

        it 'gives an error for the subjects' do
          expect(subject.errors.full_messages).to include('Select a subject')
        end
      end

      context 'if subjects are empty' do
        let(:course) { create(:course) }

        it 'passes validation' do
          expect(course.valid?).to be_truthy
        end
      end

      context 'course has been assigned secondary level' do
        let(:course) { create(:course, level: 'secondary', subjects: [find_or_create(:secondary_subject, :english)]) }

        context 'modern foreign languages' do
          it 'validates even with multiple languages' do
            course.subjects = [modern_languages, find_or_create(:modern_languages_subject, :japanese), find_or_create(:modern_languages_subject, :french)]
            expect(course.valid?).to be_truthy
          end
        end

        it 'validates if the subject is of that level' do
          course.subjects = [find_or_create(:secondary_subject, :mathematics)]
          expect(course.valid?).to be_truthy
        end

        it 'does not validate if the subject is not of that level' do
          course.subjects = [find_or_create(:primary_subject, :primary_with_mathematics)]
          expect(course.valid?).to be_falsey
          expect(course.errors[:subjects]).to eq(['Subject must be secondary'])
        end

        it 'validates if there are only 2 subjects' do
          course.subjects = [find_or_create(:secondary_subject, :mathematics), find_or_create(:secondary_subject, :english)]
          expect(course.valid?).to be_truthy
          expect(course.errors[:subjects]).to eq([])
        end

        it 'does not validate if there are more than 2 subjects' do
          course.subjects = [find_or_create(:secondary_subject, :mathematics), find_or_create(:secondary_subject, :english), find_or_create(:secondary_subject, :history)]
          expect(course.valid?).to be_falsey
          expect(course.errors[:subjects]).to eq(['has too many subjects'])
        end
      end

      context 'course has been assigned primary level' do
        let(:course) { create(:course, level: :primary, subjects: [find_or_create(:primary_subject, :primary_with_english)]) }

        it 'validates if the subject is of that level' do
          course.subjects = [find_or_create(:primary_subject, :primary_with_mathematics)]
          expect(course.valid?).to be_truthy
        end

        it 'does not validate if the subject is not of that level' do
          course.subjects = [find_or_create(:secondary_subject, :mathematics)]
          expect(course.valid?).to be_falsey
          expect(course.errors[:subjects]).to eq(['Subject must be primary'])
        end

        it 'does not validate if there is more than one subject' do
          course.subjects = [find_or_create(:primary_subject, :primary_with_mathematics), find_or_create(:primary_subject, :primary_with_english)]
          expect(course.valid?).to be_falsey
          expect(course.errors[:subjects]).to eq(['has too many subjects'])
        end
      end

      context 'course has been assigned further education level' do
        let(:course) { create(:course, :infer_level, qualification: 'pgce', subjects: [find_or_create(:further_education_subject)]) }

        it 'validates if the subject is of that level' do
          course.subjects = [find_or_create(:further_education_subject)]
          expect(course.valid?).to be_truthy
        end

        it 'does not validate if the subject is not of that level' do
          course.subjects = [find_or_create(:secondary_subject, :biology)]
          expect(course.valid?).to be_falsey
          expect(course.errors[:subjects]).to eq(['Subject must be further education'])
        end

        it 'does not validate if there is more than one subject' do
          course.subjects = [find_or_create(:further_education_subject), find_or_create(:primary_subject)]
          expect(course.valid?).to be_falsey
          expect(course.errors[:subjects]).to eq(['has too many subjects'])
        end
      end

      describe 'validate_degree_requirements_publishable' do
        let(:next_recruitment_cycle) { create(:recruitment_cycle, :next) }
        let(:provider) { create(:provider, recruitment_cycle: next_recruitment_cycle) }
        let(:course_with_degree_grade) { create(:course, provider:) }
        let(:course_without_degree_grade) { create(:course, provider:, degree_grade: nil) }

        context 'when degree grade is present' do
          it 'returns true and does not add an error' do
            expect(course_with_degree_grade.validate_degree_requirements_publishable).to be true
            expect(course_without_degree_grade.errors).to be_empty
          end
        end

        context 'when degree grade is nil' do
          it 'returns false and adds an error' do
            expect(course_without_degree_grade.validate_degree_requirements_publishable).to be false
            expect(course_without_degree_grade.errors.count).to eq 1
            expect(course_without_degree_grade.errors.first.type).to eq :degree_requirements_not_publishable
          end
        end
      end

      describe 'validate_gcse_requirements_publishable' do
        let(:next_recruitment_cycle) { create(:recruitment_cycle, :next) }
        let(:provider) { create(:provider, recruitment_cycle: next_recruitment_cycle) }
        let(:publishable_course) { create(:course, provider:, accept_pending_gcse: true, accept_gcse_equivalency: false) }
        let(:unpublishable_course) { create(:course, provider:, accept_pending_gcse: nil) }

        context 'when accept_pending_gcse and accept_gcse_equivalency are present' do
          it 'returns true and does not add an error' do
            expect(publishable_course.validate_gcse_requirements_publishable).to be true
            expect(publishable_course.errors).to be_empty
          end
        end

        context 'when accept_pending_gcse or accept_gcse_equivalency is nil' do
          it 'returns false and adds an error' do
            expect(unpublishable_course.validate_gcse_requirements_publishable).to be false
            expect(unpublishable_course.errors.count).to eq 1
            expect(unpublishable_course.errors.first.type).to eq :gcse_requirements_not_publishable
          end
        end
      end

      describe 'training provider must have partnership with accrediting provider' do
        context 'with accredited enrichments' do
          before do
            allow(Settings.features).to receive(:provider_partnerships).and_return(false)
          end

          let(:course) { create(:course, :publishable, accredited: false) }

          it 'is invalid to publish when accrediting provider has no relationship with training provider' do
            expect(subject).to be_publishable
          end
        end

        context 'with accredited partnerships' do
          before do
            allow(Settings.features).to receive(:provider_partnerships).and_return(true)
          end

          let(:course) { create(:course, :publishable, accredited: false) }

          it 'is invalid to publish when accrediting provider has no relationship with training provider' do
            expect(subject).to be_publishable
          end
        end
      end
    end
  end

  describe 'scopes' do
    describe 'canonical' do
      let(:provider_a) { create(:provider, provider_name: 'Provider A') }
      let(:course_a) do
        create(:course,
               name: 'Course A',
               course_code: 'AAA',
               provider: provider_a)
      end

      let(:another_course_a) do
        create(:course,
               name: 'Course A',
               course_code: 'BBB',
               provider: provider_a)
      end

      let(:course_a_with_provider_b) do
        create(:course,
               name: 'Course A',
               course_code: 'AAA',
               provider: provider_b)
      end

      let(:course_a_with_provider_b_with_different_course_code) do
        create(:course,
               name: 'Course A',
               course_code: 'AAB',
               provider: provider_b)
      end

      let(:course_b) do
        create(
          :course,
          name: 'Course B',
          provider: provider_a
        )
      end

      let(:provider_b) { create(:provider, provider_name: 'Provider B') }
      let(:course_c) do
        create(
          :course,
          name: 'Course C',
          provider: provider_b
        )
      end

      let(:course_d) do
        create(
          :course,
          name: 'Course D',
          provider: provider_b
        )
      end

      before do
        course_d
        course_c
        course_a
        course_b
      end

      describe '.ascending_provider_canonical_order' do
        subject { described_class.ascending_provider_canonical_order }

        it 'sorts in ascending order of provider name and course name' do
          expect(subject).to eq([course_a, course_b, course_c, course_d])
        end

        context 'when there are multiple courses with the same name' do
          before { another_course_a }

          it 'sorts by course_code' do
            expect(subject).to eq([course_a, another_course_a, course_b, course_c, course_d])
          end
        end
      end

      describe '.descending_provider_canonical_order' do
        subject { described_class.descending_provider_canonical_order }

        it 'sorts in descending order of provider name' do
          expect(subject).to eq([course_c, course_d, course_a, another_course_a, course_b])
        end

        context 'when there are multiple courses with the same name' do
          before { another_course_a }

          it 'sorts by course_code' do
            expect(subject).to eq([course_c, course_d, course_a, another_course_a, course_b])
          end
        end
      end

      describe '.ascending_course_canonical_order' do
        subject { described_class.ascending_course_canonical_order }

        it 'sorts in ascending order of course name' do
          expect(subject).to eq([course_a, course_b, course_c, course_d])
        end

        context 'when there are multiple courses with the same name' do
          before do
            course_a_with_provider_b
            another_course_a
          end

          it 'sorts by provider_name' do
            expect(subject).to eq([course_a, another_course_a, course_a_with_provider_b, course_b, course_c, course_d])
          end

          context 'when there are multiple providers with the same name' do
            before { course_a_with_provider_b_with_different_course_code }

            it 'sorts by course_code' do
              expect(subject).to eq([course_a,
                                     another_course_a,
                                     course_a_with_provider_b,
                                     course_a_with_provider_b_with_different_course_code,
                                     course_b,
                                     course_c,
                                     course_d])
            end
          end
        end
      end

      describe '.descending_course_canonical_order' do
        subject { described_class.descending_course_canonical_order }

        it 'sorts in descending order of course name' do
          expect(subject).to eq([course_d, course_c, course_b, course_a])
        end

        context 'when there are multiple courses with the same name' do
          before do
            course_a_with_provider_b
            another_course_a
          end

          it 'sorts by provider_name' do
            expect(subject).to eq([course_d, course_c, course_b, course_a, another_course_a, course_a_with_provider_b])
          end

          context 'when there are multiple providers with the same name' do
            before { course_a_with_provider_b_with_different_course_code }

            it 'sorts by course_code' do
              expect(subject).to eq([course_d,
                                     course_c,
                                     course_b,
                                     course_a,
                                     another_course_a,
                                     course_a_with_provider_b,
                                     course_a_with_provider_b_with_different_course_code])
            end
          end
        end
      end
    end

    describe '.accredited_provider_order' do
      subject { described_class.accredited_provider_order(provider.provider_name) }

      let(:provider) { create(:provider) }
      let(:delivered_course) { create(:course, provider:) }
      let(:accredited_course) { create(:course, accrediting_provider: provider) }

      before do
        accredited_course
        delivered_course
      end

      it 'returns courses accredited after courses delivered' do
        expect(subject).to eq([delivered_course, accredited_course])
      end
    end

    describe 'case_insensitive_search' do
      subject { described_class.case_insensitive_search('2vVZ') }

      let(:course) { create(:course, course_code: '2VvZ') }

      it 'returns correct course with incorrect' do
        expect(subject).to eq([course])
      end
    end

    describe '.by_name_(ascending|descending)' do
      let(:course_a) do
        create(:course, name: 'Course A')
      end

      let(:course_b) do
        create(:course, name: 'Course B')
      end

      before do
        course_a
        course_b
      end

      describe '.by_name_ascending' do
        it 'sorts in ascending order of provider name' do
          expect(described_class.by_name_ascending).to eq([course_a, course_b])
        end
      end

      describe '.by_name_descending' do
        it 'sorts in descending order of provider name' do
          expect(described_class.by_name_descending).to eq([course_b, course_a])
        end
      end
    end

    describe '.changed_since' do
      context 'with no parameters' do
        subject { described_class.changed_since(nil) }

        let!(:old_course) { create(:course, age: 1.hour.ago) }
        let!(:course) { create(:course, age: 1.hour.ago) }

        it { is_expected.to include course }
        it { is_expected.to include old_course }
      end

      context 'with a course that was just updated' do
        subject { described_class.changed_since(10.minutes.ago) }

        let(:course) { create(:course, age: 1.hour.ago) }
        let!(:old_course) { create(:course, age: 1.hour.ago) }

        before { course.touch }

        it { is_expected.to include course }
        it { is_expected.not_to include old_course }
      end

      context 'with a course that has been changed less than a second after the given timestamp' do
        subject { described_class.changed_since(timestamp) }

        let(:timestamp) { 5.minutes.ago }
        let(:course) { create(:course, changed_at: timestamp + 0.001.seconds) }

        it { is_expected.to include course }
      end

      context 'with a course that has been changed exactly at the given timestamp' do
        subject { described_class.changed_since(timestamp) }

        let(:timestamp) { 10.minutes.ago }
        let(:course) { create(:course, changed_at: timestamp) }

        it { is_expected.not_to include course }
      end
    end

    describe '.within' do
      let(:published_enrichment) { build(:course_enrichment, :published) }
      let(:enrichments) { [published_enrichment] }
      let(:course1) do
        create(
          :course,
          enrichments:,
          site_statuses: [
            build(:site_status, :findable, site: build(:site, longitude: 0, latitude: 0))
          ]
        )
      end

      let(:course2) do
        create(
          :course,
          enrichments:,
          site_statuses: [
            build(:site_status, :findable, site: build(:site, longitude: 32, latitude: 32))
          ]
        )
      end

      it 'returns courses in range' do
        course1
        course2
        courses_within_range = described_class.within(16, origin: [0, 0])

        expect(courses_within_range.count).to eq(1)
        expect(described_class.within(16, origin: [0, 0])).to contain_exactly(course1)
      end
    end

    describe '.published' do
      subject { described_class.published }

      let(:test_course) { create(:course, enrichments:) }

      before do
        test_course
      end

      context 'when initial draft course' do
        let(:enrichments) { [build(:course_enrichment, :initial_draft)] }

        it 'is not returned' do
          expect(subject).to be_empty
        end
      end

      context 'when draft course' do
        let(:enrichments) { [build(:course_enrichment)] }

        it 'is not returned' do
          expect(subject).to be_empty
        end
      end

      context 'when rolled over course' do
        let(:enrichments) { [build(:course_enrichment, :rolled_over)] }

        it 'is not returned' do
          expect(subject).to be_empty
        end
      end

      context 'when published' do
        let(:enrichments) { [build(:course_enrichment, :published)] }

        it 'is returned' do
          expect(subject).to contain_exactly(test_course)
        end
      end

      context 'when there are multiple enrichments' do
        context 'published is present' do
          let(:enrichments) { [build(:course_enrichment, :published)] }

          before do
            test_course.enrichments << build(:course_enrichment, :withdrawn)
          end

          it 'is returned' do
            expect(subject).to contain_exactly(test_course)
          end
        end

        context 'and published not present' do
          let(:enrichments) { [build(:course_enrichment, :withdrawn)] }

          before do
            test_course.enrichments << build(:course_enrichment, :initial_draft)
          end

          it 'is not returned' do
            expect(subject).to be_empty
          end
        end
      end
    end

    describe '.with_recruitment_cycle' do
      subject { described_class.with_recruitment_cycle(provider.recruitment_cycle.year) }

      let(:test_course) { create(:course, provider:) }

      before { test_course }

      context 'course is in recruitment cycle' do
        let(:provider) { create(:provider) }

        it 'is returned' do
          expect(subject).to contain_exactly(test_course)
        end
      end

      context 'course is not in recruitment cycle' do
        let(:provider) { create(:provider, :next_recruitment_cycle) }

        it 'is not returned' do
          expect(subject).to contain_exactly(test_course)
        end
      end
    end

    describe '.findable' do
      subject { described_class.findable }

      let(:test_course) { create(:course, site_statuses:) }

      before { test_course }

      context 'course is findable' do
        let(:site_statuses) do
          [
            build(:site_status, :findable)
          ]
        end

        it 'is returned' do
          expect(subject).to contain_exactly(test_course)
        end
      end

      context 'course is not findable' do
        let(:site_statuses) do
          [
            build(:site_status)
          ]
        end

        it 'is not returned' do
          expect(subject).to be_empty
        end
      end
    end

    describe '.with_vacancies' do
      subject { described_class.with_vacancies }

      let(:test_course) { create(:course, site_statuses:) }

      before { test_course }

      context 'course has vacancies' do
        let(:site_statuses) do
          [
            build(:site_status, :with_any_vacancy, :findable)
          ]
        end

        it 'is returned' do
          expect(subject).to contain_exactly(test_course)
        end
      end

      context 'course has no vacancies' do
        let(:site_statuses) do
          [
            build(:site_status, :no_vacancies, :findable)
          ]
        end

        it 'is not returned' do
          expect(subject).to be_empty
        end
      end

      context 'course is not findable' do
        let(:site_statuses) do
          [
            build(:site_status, :with_any_vacancy)
          ]
        end

        it 'is not returned' do
          expect(subject).to be_empty
        end
      end
    end

    describe '.with_study_modes' do
      subject { described_class.with_study_modes(study_modes) }

      let(:course_part_time) { create(:course, study_mode: :part_time) }
      let(:course_full_time) { create(:course, study_mode: :full_time) }
      let(:course_both) { create(:course, study_mode: :full_time_or_part_time) }

      before do
        course_both
        course_full_time
        course_part_time
      end

      context 'full_time' do
        let(:study_modes) { 'full_time' }

        it 'returns full time courses' do
          expect(subject).to contain_exactly(course_both, course_full_time)
        end
      end

      context 'part_time' do
        let(:study_modes) { 'part_time' }

        it 'returns part time courses' do
          expect(subject).to contain_exactly(course_both, course_part_time)
        end
      end

      context 'full time and part_time' do
        let(:study_modes) { %w[full_time part_time] }

        it 'returns all' do
          expect(subject).to contain_exactly(course_both, course_part_time, course_full_time)
        end
      end
    end

    describe '.with_funding_types' do
      subject { described_class.with_funding_types(funding_types) }

      let(:fee_course_higher_education) { create(:course, :with_higher_education) }
      let(:fee_course_scitt) { create(:course, :with_scitt) }
      let(:fee_course_school_direct) { create(:course, :with_school_direct) }
      let(:salary_course) { create(:course, :with_salary) }
      let(:apprenticeship_course) { create(:course, :with_apprenticeship) }

      context 'fee courses' do
        let(:funding_types) { %w[fee] }

        before do
          fee_course_higher_education
          fee_course_scitt
          fee_course_school_direct
          salary_course
          apprenticeship_course
        end

        it 'returns fee courses' do
          expect(subject).to contain_exactly(fee_course_higher_education, fee_course_school_direct, fee_course_scitt)
        end
      end

      context 'salary' do
        let(:funding_types) { %w[salary] }

        before do
          salary_course
          apprenticeship_course
          fee_course_higher_education
        end

        it 'returns fee courses' do
          expect(subject).to contain_exactly(salary_course)
        end
      end

      context 'apprenticeship' do
        let(:funding_types) { %w[apprenticeship] }

        before do
          apprenticeship_course
          salary_course
          fee_course_scitt
        end

        it 'returns fee courses' do
          expect(subject).to contain_exactly(apprenticeship_course)
        end
      end
    end

    describe '.with_degree_grades' do
      subject { described_class.with_degree_grades(degree_grades) }

      let(:two_two_course) { create(:course, degree_grade: :two_two) }
      let(:third_class_course) { create(:course, degree_grade: :third_class) }
      let(:minimum_degree_not_required_course) { create(:course, degree_grade: :not_required) }

      before do
        two_two_course
        third_class_course
        minimum_degree_not_required_course
      end

      context '2:2 courses' do
        let(:degree_grades) { %w[two_two] }

        it "returns courses with a 'two_two' degree grade" do
          expect(subject).to contain_exactly(two_two_course)
        end
      end

      context 'third class degree courses' do
        let(:degree_grades) { %w[third_class] }

        it "returns courses with a 'third_class' degree grade" do
          expect(subject).to contain_exactly(third_class_course)
        end
      end

      context 'no requirement degree courses' do
        let(:degree_grades) { %w[not_required] }

        it "returns courses with a 'not_required' degree grade" do
          expect(subject).to contain_exactly(minimum_degree_not_required_course)
        end
      end
    end

    describe '.with_salary' do
      subject { described_class.with_salary }

      let!(:course_higher_education_programme) do
        create(:course, program_type: :higher_education_programme, funding: :fee)
      end

      let!(:course_scitt_salaried_programme) do
        create(:course, program_type: :scitt_salaried_programme, funding: :salary)
      end

      let!(:course_higher_education_salaried_programme) do
        create(:course, program_type: :higher_education_salaried_programme, funding: :salary)
      end

      let!(:course_school_direct_training_programme) do
        create(:course, program_type: :school_direct_training_programme, funding: :fee)
      end

      let!(:course_school_direct_salaried_training_programme) do
        create(:course, program_type: :school_direct_salaried_training_programme, funding: :salary)
      end

      let!(:course_scitt_programme) { create(:course, program_type: :scitt_programme, funding: :fee) }
      let!(:course_pg_teaching_apprenticeship) do
        create(:course, program_type: :pg_teaching_apprenticeship, funding: :apprenticeship)
      end

      it 'only returns salaried training programme' do
        expect(subject).to contain_exactly(
          course_scitt_salaried_programme,
          course_higher_education_salaried_programme,
          course_school_direct_salaried_training_programme,
          course_pg_teaching_apprenticeship
        )
      end
    end

    describe '.with_qualifications' do
      subject { described_class.with_qualifications(qualifications) }

      let(:course_qts) { TestDataCache.get(:course, :resulting_in_qts) }
      let(:course_pgce_with_qts) { TestDataCache.get(:course, :resulting_in_pgce_with_qts) }
      let(:course_pgde_with_qts) { TestDataCache.get(:course, :resulting_in_pgde_with_qts) }
      let(:course_pgce) { TestDataCache.get(:course, :resulting_in_pgce) }
      let(:course_pgde) { TestDataCache.get(:course, :resulting_in_pgde) }

      before do
        course_qts
        course_pgce_with_qts
        course_pgde_with_qts
        course_pgce
        course_pgde
      end

      context 'qts' do
        let(:qualifications) { 'qts' }

        it 'returns qts courses' do
          expect(subject).to contain_exactly(course_qts)
        end
      end

      context 'pgce_with_qts' do
        let(:qualifications) { 'pgce_with_qts' }

        it 'returns pgce_with_qts courses' do
          expect(subject).to contain_exactly(course_pgce_with_qts)
        end
      end

      context 'pgde_with_qts' do
        let(:qualifications) { 'pgde_with_qts' }

        it 'returns pgde_with_qts courses' do
          expect(subject).to contain_exactly(course_pgde_with_qts)
        end
      end

      context 'pgce' do
        let(:qualifications) { 'pgce' }

        it 'returns pgce' do
          expect(subject).to contain_exactly(course_pgce)
        end
      end

      context 'pgde' do
        let(:qualifications) { 'pgde' }

        it 'returns pgce' do
          expect(subject).to contain_exactly(course_pgde)
        end
      end

      context 'multiple qualifications' do
        let(:qualifications) { %w[pgde pgce qts] }

        it 'returns all requested' do
          expect(subject).to contain_exactly(course_pgce, course_pgde, course_qts)
        end
      end
    end

    describe '.with_provider_name' do
      let(:provider) { create(:provider, provider_name: 'ACME') }
      let(:provider2) { create(:provider, provider_name: 'DAVE') }
      let(:course) { create(:course, provider:) }
      let(:provider_name) { 'ACME' }
      let(:accredited_provider_name) { 'University of Awesome' }
      let(:accredited_provider) { build(:provider, :accredited_provider, provider_name: accredited_provider_name) }
      let(:accredited_course) { create(:course, accrediting_provider: accredited_provider) }

      before do
        provider
        provider2
        course
        provider_name
      end

      context 'with an existing provider name' do
        subject { described_class.with_provider_name(provider_name) }

        it { is_expected.to contain_exactly(course) }
      end

      context 'with a provider name with no courses' do
        subject { described_class.with_provider_name('DAVE') }

        it { is_expected.to be_empty }
      end

      context 'with an accredited provider name' do
        subject { described_class.with_provider_name(accredited_provider_name) }

        it { is_expected.to contain_exactly(accredited_course) }
      end
    end

    describe '.with_accredited_bodies' do
      context 'course with an accredited provider' do
        subject { described_class.with_accredited_bodies(accredited_provider.provider_code) }

        let!(:provider) { create(:provider) }
        let!(:course) { create(:course, provider:) }
        let!(:accredited_provider) { create(:provider, :accredited_provider) }
        let!(:accredited_course) { create(:course, accrediting_provider: accredited_provider) }

        it 'returns courses for which the provider is the accredited provider' do
          expect(subject).to contain_exactly(accredited_course)
        end
      end
    end

    context '::findable && ::with_vacancies' do
      let(:course_in_scope) { create(:course) }
      let(:course_not_in_scope) { create(:course) }

      before do
        create(:site_status, :published, :running, :full_time_vacancies, course: course_in_scope)
        create(:site_status, :unpublished, :running, :full_time_vacancies, course: course_not_in_scope)
        create(:site_status, :published, :running, :no_vacancies, course: course_not_in_scope)
      end

      it 'scopes are combined with AND and not OR' do
        expect(described_class.findable.with_vacancies.to_a).to eql([course_in_scope])
      end
    end

    describe '.engineers_teach_physics' do
      subject { described_class.engineers_teach_physics }

      context "when the course has the campaign 'engineers_teach_physics'" do
        let(:course) { create(:course, :engineers_teach_physics) }

        it 'returns the course' do
          expect(subject).to eq [course]
        end
      end

      context 'when the course has no campaign' do
        let(:course) { create(:course, provider:) }

        it 'does not return the course' do
          expect(subject).to eq []
        end
      end
    end

    describe '.can_sponsor_visa' do
      subject { described_class.can_sponsor_visa }

      let(:provider) { create(:provider) }
      let(:course) { create(:course, provider: create(:provider)) }

      before do
        course
      end

      context 'when the provider can sponsor skilled worker visas' do
        context 'and is a salaried course' do
          let(:course) { create(:course, :salary_type_based, :can_sponsor_skilled_worker_visa, provider:) }

          it 'returns the course' do
            expect(subject).to eq [course]
          end
        end

        context 'and is non-salaried course' do
          let(:course) { create(:course, :fee_type_based, :can_sponsor_skilled_worker_visa, provider:) }

          it 'does not return the course' do
            expect(subject).to eq []
          end
        end
      end

      context 'when the provider can sponsor student visas' do
        context 'and is non-salaried course' do
          let(:course) { create(:course, :fee_type_based, :can_sponsor_student_visa, provider:) }

          it 'returns the course' do
            expect(subject).to eq [course]
          end
        end

        context 'and is a salaried course' do
          let(:course) { create(:course, :salary_type_based, :can_sponsor_student_visa, provider:) }

          it 'does not return the course' do
            expect(subject).to eq []
          end
        end
      end

      context 'when the provider cannot sponsor visas' do
        it 'does not return the course' do
          expect(subject).to eq []
        end
      end
    end
  end

  describe 'changed_at' do
    it 'is set on create' do
      course = create(:course)
      expect(course.changed_at).to be_present
      expect(course.changed_at).to eq course.updated_at
    end

    it 'is set on update' do
      Timecop.freeze do
        course = create(:course, changed_at: 1.hour.ago)
        course.touch
        expect(course.changed_at).to eq course.updated_at
        expect(course.changed_at).to be_within(1.second).of Time.now.utc
      end
    end
  end

  its(:recruitment_cycle) { is_expected.to eq find(:recruitment_cycle) }

  describe 'no site statuses' do
    its(:site_statuses) { is_expected.to be_empty }
    its(:findable?) { is_expected.to be false }
    its(:open_for_applications?) { is_expected.to be false }
    its(:has_vacancies?) { is_expected.to be false }
  end

  context 'with sites' do
    subject { create(:course, provider:, site_statuses: [first_site_status, second_site_status]) }

    let(:provider) { build(:provider) }
    let(:first_site) { build(:site, provider:) }
    let(:first_site_status) { create(:site_status, :running, site: first_site) }
    let(:second_site) { build(:site, provider:) }
    let(:second_site_status) { create(:site_status, :suspended, site: second_site) }
    let(:new_site) { build(:site, provider:) }

    describe '#sites' do
      it 'onlies return new and running sites' do
        expect(subject.sites.to_a).to eq([first_site])
      end
    end

    describe 'sites=' do
      let(:new_site_status) { build(:site_status, :new_status, site: site_with_new_site_status) }
      let(:site_with_new_site_status) { build(:site, provider:) }

      before do
        subject.sites = [second_site, new_site]
      end

      context 'with a ucas_status of new' do
        subject { create(:course, provider:, site_statuses: [new_site_status]) }

        it 'does not set the site to running' do
          expect(second_site_status.reload.status).to eq('suspended')
        end

        it 'destroys the old site status' do
          expect(SiteStatus.where(id: new_site_status.id)).to be_empty
        end
      end

      context 'With an unpersisted course' do
        let(:course) { build(:course) }

        before { course.sites = [first_site, second_site] }

        it 'sets the sites' do
          expect(course.sites).to eq([first_site, second_site])
        end

        it 'does not persist the course' do
          expect(course).not_to be_persisted
        end

        context 'Which is then saved' do
          it 'onlies have two site statuses' do
            course.save
            expect(course.site_statuses.count).to eq(2)
          end
        end
      end

      it 'assigns new sites' do
        expect(subject.sites.to_a).to eq([second_site, new_site])
      end

      it 'sets the sites to running' do
        expect(second_site_status.reload.status).to eq('running')
      end

      it 'sets old site_status to suspended' do
        expect(first_site_status.reload.status).to eq('suspended')
      end
    end
  end

  context 'with site statuses' do
    subject { create(:course, provider:, site_statuses:) }

    let(:provider) { build(:provider, sites: [site]) }
    let(:site) { build(:site) }
    let(:new_site_status) { build(:site_status, :new_status, site:) }
    let(:new_site_status2) { build(:site_status, :new_status, site:) }
    let(:findable) { build(:site_status, :findable, site:) }
    let(:suspended) { build(:site_status, :suspended, site:) }
    let(:with_any_vacancy) { build(:site_status, :with_any_vacancy, site:) }
    let(:default) { build(:site_status, site:) }
    let(:site_status_with_no_vacancies) { build(:site_status, :no_vacancies, site:) }
    let(:findable_without_vacancies) { build(:site_status, :findable, :no_vacancies, site:) }
    let(:findable_with_vacancies) { build(:site_status, :findable, :with_any_vacancy, site:) }
    let(:published_suspended_with_any_vacancy) { build(:site_status, :published, :discontinued, :with_any_vacancy, site:) }
    let(:published_discontinued_with_any_vacancy) { build(:site_status, :published, :suspended, :with_any_vacancy, site:) }
    let(:published_discontinued_with_no_vacancies) { build(:site_status, :published, :suspended, :no_vacancies, site:) }
    let(:site_statuses) { [] }

    describe '#findable_site_statuses' do
      context 'with a site_statuses association that have been loaded' do
        it 'uses #select on the association' do
          allow(subject.site_statuses).to receive(:select).and_return([])

          subject.findable_site_statuses

          expect(subject.site_statuses).to have_received(:select)
        end

        context 'with a findable site' do
          let(:site_statuses) { [findable] }

          its(:findable_site_statuses) { is_expected.not_to be_empty }
        end

        context 'with no findable sites' do
          let(:site_statuses) { [suspended] }

          its(:findable_site_statuses) { is_expected.to be_empty }
        end

        context 'with at least one findable sites' do
          let(:site_statuses) { [findable, suspended] }

          its(:findable_site_statuses) { is_expected.not_to be_empty }
        end
      end

      context 'with a site_statuses association that has not been loaded' do
        it 'uses #select on the association' do
          course_with_site_statuses_not_loaded = described_class.find(course.id)
          allow(course_with_site_statuses_not_loaded.site_statuses)
            .to receive(:findable).and_return([])

          course_with_site_statuses_not_loaded.findable_site_statuses

          expect(course_with_site_statuses_not_loaded.site_statuses)
            .to have_received(:findable)
        end

        context 'with a findable site' do
          let(:site_statuses) { [findable] }

          its(:findable_site_statuses) { is_expected.not_to be_empty }
        end

        context 'with no findable sites' do
          let(:site_statuses) { [suspended] }

          its(:findable_site_statuses) { is_expected.to be_empty }
        end

        context 'with at least one findable sites' do
          let(:site_statuses) { [findable, suspended] }

          its(:findable_site_statuses) { is_expected.not_to be_empty }
        end
      end
    end

    describe '#findable?' do
      context 'when #findable_site_statuses returns site statuses' do
        it 'returns true' do
          allow(course).to receive(:findable_site_statuses).and_return([findable])
          expect(course.findable?).to be_truthy
        end
      end

      context 'when #findable_site_statuses returns no site statuses' do
        it 'returns false' do
          allow(course).to receive(:findable_site_statuses).and_return([])
          expect(course.findable?).to be_falsey
        end
      end
    end

    describe '#has_vacancies?' do
      context 'for a single site status that has vacancies' do
        let(:site_statuses) { [findable, with_any_vacancy] }

        its(:has_vacancies?) { is_expected.to be true }
      end

      context 'for a site status with vacancies and others without' do
        let(:site_statuses) { [findable_with_vacancies, findable_without_vacancies] }

        its(:has_vacancies?) { is_expected.to be true }
      end

      context 'when none of the sites have vacancies' do
        let(:site_statuses) { [findable_without_vacancies, findable_without_vacancies] }

        its(:has_vacancies?) { is_expected.to be false }
      end

      context 'when only discontinued and suspended site statuses have vacancies' do
        let(:site_statuses) { [findable_without_vacancies, published_suspended_with_any_vacancy, published_discontinued_with_any_vacancy] }

        its(:has_vacancies?) { is_expected.to be false }
      end
    end

    describe '#has_vacancies? (when site_statuses not loaded)' do
      subject do
        create(:course, site_statuses:).reload
      end

      context 'for a single site status that has vacancies' do
        let(:site_statuses) { [findable, with_any_vacancy] }

        its(:has_vacancies?) { is_expected.to be true }
      end

      context 'for a site status with vacancies and others without' do
        let(:site_statuses) { [findable_with_vacancies, findable_without_vacancies] }

        its(:has_vacancies?) { is_expected.to be true }
      end

      context 'when none of the sites have vacancies' do
        let(:site_statuses) { [findable_without_vacancies, findable_without_vacancies] }

        its(:has_vacancies?) { is_expected.to be false }
      end

      context 'when only discontinued and suspended site statuses have vacancies' do
        let(:site_statuses) { [findable_without_vacancies, published_suspended_with_any_vacancy, published_discontinued_with_any_vacancy] }

        its(:has_vacancies?) { is_expected.to be false }
      end
    end

    describe '#open_for_applications?' do
      subject { course }

      let(:site_statuses) { [] }

      let(:applications_open_from) { Time.now.utc }
      let(:application_status) { :open }

      let(:course) do
        create(:course,
               site_statuses:,
               application_status:,
               applications_open_from:)
      end

      context 'no site statuses' do
        context 'applications_open_from is in present or past' do
          its(:open_for_applications?) { is_expected.to be false }
        end

        context 'applications_open_from is in future' do
          let(:applications_open_from) { Time.now.utc + 1.day }

          its(:open_for_applications?) { is_expected.to be false }
        end
      end

      context 'with site statuses' do
        context 'with only a single findable site statuses' do
          let(:site_statuses) { [findable] }

          context 'applications_open_from is in present or past' do
            its(:open_for_applications?) { is_expected.to be true }
          end

          context 'applications_open_from is in future' do
            let(:applications_open_from) { Time.now.utc + 1.day }

            its(:open_for_applications?) { is_expected.to be false }
          end
        end

        context 'with at least a single findable site statuses' do
          let(:site_statuses) do
            [default, findable, new_site_status,
             site_status_with_no_vacancies, suspended, with_any_vacancy]
          end

          context 'applications_open_from is in present or past' do
            its(:open_for_applications?) { is_expected.to be true }
          end

          context 'applications_open_from is in future' do
            let(:applications_open_from) { Time.now.utc + 1.day }

            its(:open_for_applications?) { is_expected.to be false }
          end
        end

        context 'with no findable site statuses' do
          let(:site_statuses) do
            [default, new_site_status, site_status_with_no_vacancies,
             suspended, with_any_vacancy]
          end

          context 'applications_open_from is in present or past' do
            its(:open_for_applications?) { is_expected.to be false }
          end

          context 'applications_open_from is in future' do
            let(:applications_open_from) { Time.now.utc + 1.day }

            its(:open_for_applications?) { is_expected.to be false }
          end

          context 'findable course with vacancies' do
            let(:site_statuses) { [findable_with_vacancies] }

            its(:open_for_applications?) { is_expected.to be true }
          end

          context 'non findable course with vacancies' do
            let(:site_statuses) { [published_discontinued_with_any_vacancy] }

            its(:open_for_applications?) { is_expected.to be false }
          end

          context 'findable course with no vacancies' do
            let(:site_statuses) { [findable_without_vacancies] }
            let(:application_status) { :closed }

            its(:open_for_applications?) { is_expected.to be false }
          end

          context 'non findable course with no vacancies' do
            let(:site_statuses) { [published_discontinued_with_no_vacancies] }
            let(:application_status) { :closed }

            its(:open_for_applications?) { is_expected.to be false }
          end
        end
      end
    end

    describe 'open_for_applications? (when site_statuses not loaded)' do
      subject do
        course.reload
      end

      let(:site_statuses) { [] }

      let(:applications_open_from) { Time.now.utc }
      let(:application_status) { :open }

      let(:course) do
        create(:course,
               site_statuses:,
               application_status:,
               applications_open_from:)
      end

      context 'no site statuses' do
        context 'applications_open_from is in present or past' do
          its(:open_for_applications?) { is_expected.to be false }
        end

        context 'applications_open_from is in future' do
          let(:applications_open_from) { Time.now.utc + 1.day }

          its(:open_for_applications?) { is_expected.to be false }
        end
      end

      context 'with site statuses' do
        context 'with only a single findable site statuses' do
          let(:site_statuses) { [findable] }

          context 'applications_open_from is in present or past' do
            its(:open_for_applications?) { is_expected.to be true }
          end

          context 'applications_open_from is in future' do
            let(:applications_open_from) { Time.now.utc + 1.day }

            its(:open_for_applications?) { is_expected.to be false }
          end
        end

        context 'with at least a single findable site statuses' do
          let(:site_statuses) do
            [default, findable, new_site_status,
             site_status_with_no_vacancies, suspended, with_any_vacancy]
          end

          context 'applications_open_from is in present or past' do
            its(:open_for_applications?) { is_expected.to be true }
          end

          context 'applications_open_from is in future' do
            let(:applications_open_from) { Time.now.utc + 1.day }

            its(:open_for_applications?) { is_expected.to be false }
          end
        end

        context 'with no findable site statuses' do
          let(:site_statuses) do
            [default, new_site_status, site_status_with_no_vacancies,
             suspended, with_any_vacancy]
          end

          context 'applications_open_from is in present or past' do
            its(:open_for_applications?) { is_expected.to be false }
          end

          context 'applications_open_from is in future' do
            let(:applications_open_from) { Time.now.utc + 1.day }

            its(:open_for_applications?) { is_expected.to be false }
          end
        end
      end
    end

    describe 'ucas_status' do
      context 'without any site statuses' do
        subject { create(:course) }

        its(:ucas_status) { is_expected.to eq :new }
      end

      context 'with a running site_status' do
        subject { create(:course, site_statuses: [findable]) }

        its(:ucas_status) { is_expected.to eq :running }
      end

      context 'with a new site_status' do
        subject { create(:course, site_statuses: [new]) }

        let(:new) { build(:site_status, :new_status) }

        its(:ucas_status) { is_expected.to eq :new }
      end

      context 'with a not running site_status' do
        subject { create(:course, site_statuses: [suspended]) }

        let(:suspended) { build(:site_status, :suspended) }

        its(:ucas_status) { is_expected.to eq :not_running }
      end
    end

    describe '#not_new' do
      let(:new_course) do
        create(:course, site_statuses: [new_site_status])
      end

      let(:suspended_course_with_new_site) do
        create(:course, site_statuses: [suspended, new_site_status2])
      end

      let(:findable_course) do
        create(:course, site_statuses: [findable])
      end

      it 'only returns courses that arent new' do
        new_course
        findable_course
        suspended_course_with_new_site

        expect(described_class.not_new.count).to eq(2)
        expect(described_class.not_new.first.sites.count).to eq(1)
        expect(described_class.not_new.second.sites.count).to eq(1)
      end
    end

    its(:site_statuses) { is_expected.to be_empty }
    its(:findable?) { is_expected.to be false }
    its(:open_for_applications?) { is_expected.to be false }
    its(:has_vacancies?) { is_expected.to be false }
  end

  describe '#study_mode_description' do
    specs = {
      full_time: 'full time',
      part_time: 'part time',
      full_time_or_part_time: 'full time or part time'
    }.freeze

    specs.each do |study_mode, expected_description|
      context study_mode.to_s do
        subject { create(:course, study_mode:) }

        its(:study_mode_description) { is_expected.to eq(expected_description) }
      end
    end
  end

  describe '#description' do
    context 'for a both full time and part time course' do
      subject do
        create(:course,
               study_mode: :full_time_or_part_time,
               program_type: :scitt_programme,
               qualification: :qts)
      end

      its(:description) { is_expected.to eq('QTS, full time or part time') }
    end

    specs = {
      'QTS, full time or part time' => {
        study_mode: :full_time_or_part_time,
        program_type: :scitt_programme,
        qualification: :qts
      },
      'PGCE with QTS full time with salary' => {
        study_mode: :full_time,
        funding: 'salary',
        program_type: :school_direct_salaried_training_programme,
        qualification: :pgce_with_qts
      },
      'Teacher degree apprenticeship with QTS' => {
        study_mode: :full_time,
        funding: 'apprenticeship',
        program_type: :teacher_degree_apprenticeship,
        qualification: :undergraduate_degree_with_qts
      }
    }.freeze

    specs.each do |expected_description, course_attributes|
      context "for #{expected_description} course" do
        subject { create(:course, course_attributes) }

        its(:description) { is_expected.to eq(expected_description) }
      end
    end

    context 'for a salaried course' do
      subject do
        create(:course,
               study_mode: :full_time,
               funding: 'salary',
               qualification: :pgce_with_qts)
      end

      its(:description) { is_expected.to eq('PGCE with QTS full time with salary') }
    end

    context 'for a teaching apprenticeship' do
      subject do
        create(:course,
               study_mode: :part_time,
               funding: 'apprenticeship',
               qualification: :pgde_with_qts)
      end

      its(:description) { is_expected.to eq('PGDE with QTS part time teaching apprenticeship') }
    end
  end

  describe 'content_status' do
    let(:course) { create(:course, enrichments: [enrichment1, enrichment2]) }
    let(:enrichment1) {  build(:course_enrichment, :subsequent_draft, created_at: Time.zone.now) }
    let(:enrichment2) {  build(:course_enrichment, :published, created_at: 1.minute.ago) }
    let(:service_spy) { spy(execute: :published_with_unpublished_changes) }
    let(:content_status) { course.content_status }

    it 'Delegate the method to the service' do
      expect(course).to delegate_method_to_service(
        :content_status,
        'Courses::ContentStatusService'
      ).with_arguments(enrichment: enrichment1)
    end
  end

  describe 'qualifications' do
    context 'course with qts qualication' do
      subject { create(:course, :resulting_in_qts) }

      its(:qualifications) { is_expected.to eq %i[qts] }
    end

    context 'course with pgce qts qualication' do
      subject { create(:course, :resulting_in_pgce_with_qts) }

      its(:qualifications) { is_expected.to eq %i[qts pgce] }
    end

    context 'course with pgde qts qualication' do
      subject { create(:course, :resulting_in_pgde_with_qts) }

      its(:qualifications) { is_expected.to eq %i[qts pgde] }
    end

    context 'course with pgce qualication' do
      subject { create(:course, :resulting_in_pgce) }

      its(:qualifications) { is_expected.to eq %i[pgce] }
    end

    context 'course with pgde qualication' do
      subject { create(:course, :resulting_in_pgde) }

      its(:qualifications) { is_expected.to eq %i[pgde] }
    end
  end

  describe '#is_send?' do
    subject { create(:course) }

    its(:is_send?) { is_expected.to be_falsey }

    context 'with a SEND subject' do
      subject { create(:course, is_send: true) }

      its(:is_send?) { is_expected.to be_truthy }
    end
  end

  context 'gcse_subjects_required' do
    context 'with primary level' do
      subject { create(:course, level: 'primary') }

      its(:level) { is_expected.to eq('primary') }
      its(:gcse_subjects_required) { is_expected.to eq(%w[maths english science]) }
    end

    context 'with secondary level' do
      subject { create(:course, level: 'secondary') }

      its(:level) { is_expected.to eq('secondary') }
      its(:gcse_subjects_required) { is_expected.to eq(%w[maths english]) }
    end

    context 'with further education level' do
      subject { create(:course, level: 'further_education') }

      its(:level) { is_expected.to eq('further_education') }
      its(:gcse_subjects_required) { is_expected.to eq([]) }
    end
  end

  describe '#gcse_grade_required' do
    its(:gcse_grade_required) { is_expected.to eq(4) }

    context 'when the provider is on the PROVIDERS_REQUIRING_GCSE_GRADE_5 list' do
      let(:course) do
        provider = create(:provider, provider_code: Course::PROVIDERS_REQUIRING_GCSE_GRADE_5.sample)
        create(:course, provider:)
      end

      its(:gcse_grade_required) { is_expected.to eq(5) }
    end

    context 'when the accrediting provider is on the PROVIDERS_REQUIRING_GCSE_GRADE_5 list' do
      let(:course) do
        provider = create(:provider)
        accrediting_provider = create(:provider, provider_code: Course::PROVIDERS_REQUIRING_GCSE_GRADE_5.sample)
        create(:course, provider:, accrediting_provider:)
      end

      its(:gcse_grade_required) { is_expected.to eq(5) }
    end
  end

  context 'bursaries and scholarships' do
    subject { create(:course, :skip_validate, level: 'secondary', subjects: [english]) }

    let(:english) { find_or_create(:secondary_subject, :english) }
    let!(:financial_incentive) { create(:financial_incentive, subject: english, bursary_amount: 255, scholarship: 1415, early_career_payments: 32) }

    it { is_expected.to have_bursary }
    it { is_expected.to have_scholarship_and_bursary }
    it { is_expected.to have_early_career_payments }

    it { expect(subject.bursary_amount).to eq('255') }
    it { expect(subject.scholarship_amount).to eq('1415') }

    context 'with multiple subjects' do
      let(:maths) { find_or_create(:secondary_subject, :mathematics) }
      let(:religious_education) { find_or_create(:secondary_subject, :religious_education) }

      context 'when main subject does not have financial incentive' do
        subject { create(:course, :skip_validate, level: 'secondary', subjects: [religious_education, english]) }

        it 'reads financial incentives from only the first subject' do
          expect(subject.bursary_amount).to be_nil
          expect(subject.has_bursary?).to be false
          expect(subject.scholarship_amount).to be_nil
          expect(subject.has_scholarship?).to be false
        end
      end

      context 'when main subject has a financial incentive' do
        subject { create(:course, :skip_validate, level: 'secondary', subjects: [maths, english]) }

        it 'reads financial incentives from only the first subject' do
          expect(subject.bursary_amount).to eq maths.financial_incentive.bursary_amount
          expect(subject.has_bursary?).to be true
          expect(subject.scholarship_amount).to eq maths.financial_incentive.scholarship
          expect(subject.has_scholarship?).to be true
        end
      end

      context 'with modern languages' do
        context 'with a language as a second subject' do
          subject { create(:course, :skip_validate, level: 'secondary', subjects: [modern_languages, french, german, spanish]) }

          let(:french) { create(:modern_languages_subject, :french) }
          let(:german) { create(:modern_languages_subject, :german) }
          let(:spanish) { create(:modern_languages_subject, :spanish) }
          let!(:french_financial_incentive) { create(:financial_incentive, subject: french, bursary_amount: '15000', scholarship: nil) }
          let!(:german_financial_incentive) { create(:financial_incentive, subject: german, bursary_amount: '14000', scholarship: nil) }
          let!(:spanish_financial_incentive) { create(:financial_incentive, subject: spanish, bursary_amount: '13000', scholarship: nil) }

          it "reads financial incentives from only the first subject, and ignores the 'Modern Languages' subject" do
            expect(subject.bursary_amount).to eq french.financial_incentive.bursary_amount
            expect(subject.has_bursary?).to be true
            expect(subject.scholarship_amount).to eq french.financial_incentive.scholarship
            expect(subject.has_scholarship?).to be false
          end
        end

        context 'with no language as a second subject' do
          subject { create(:course, :skip_validate, level: 'secondary', subjects: [modern_languages]) }

          it 'has no financial incentive' do
            expect(subject.financial_incentive).to be_nil
          end
        end
      end
    end
  end

  context 'entry requirements' do
    %i[maths science english].each do |gcse_subject|
      describe gcse_subject do
        it 'is an enum' do
          expect(subject)
            .to define_enum_for(gcse_subject)
            .backed_by_column_of_type(:integer)
            .with_values(Course::ENTRY_REQUIREMENT_OPTIONS)
            .with_suffix("for_#{gcse_subject}")
        end
      end
    end
  end

  describe 'adding and removing sites on a course' do
    subject { create(:course, site_statuses: [existing_site_status]) }

    let(:provider) { build(:provider) }
    # this code will be removed and fixed properly in the next pr
    let(:new_site) { create(:site, provider:, code: 'A') }
    # this code will be removed and fixed properly in the next pr
    let(:existing_site) { create(:site, provider:, code: 'B') }
    let(:new_site_status) { subject.site_statuses.find_by!(site: new_site) }

    context 'for running courses' do
      let(:existing_site_status) { create(:site_status, :running, :published, site: existing_site) }

      it 'suspends the site when an existing site is removed' do
        expect { subject.sites = [] }
          .to change { existing_site_status.reload.status }.from('running').to('suspended')
      end

      it 'adds a new site status and sets it to running when a new site is added' do
        expect { subject.sites = [new_site] }.to change { subject.reload.site_statuses.size }.from(1).to(2)

        expect(existing_site_status.reload.status).to eq('suspended')
        expect(new_site_status.reload.status).to eq('running')
      end
    end

    context 'for new courses' do
      let(:existing_site_status) { create(:site_status, :new_status, site: existing_site) }

      it 'sets the site to new when a new site is added' do
        expect { subject.sites = [existing_site, new_site] }.to change { subject.reload.site_statuses.size }.from(1).to(2)

        expect(existing_site_status.reload.status).to eq('new_status')
        expect(new_site_status.reload.status).to eq('new_status')
      end

      it 'keeps the site status as new when an existing site is added' do
        expect { subject.sites = [existing_site] }
          .not_to change { existing_site_status.reload.status }.from('new_status')
      end

      it 'removes the site status when an existing site is removed' do
        expect { subject.sites = [] }.to change { subject.reload.site_statuses.size }.from(1).to(0)
      end
    end

    context 'for suspended courses' do
      let(:existing_site_status) { create(:site_status, :suspended, site: existing_site) }

      it 'sets the site to running when a new site is added' do
        expect { subject.sites = [new_site] }.to change { subject.reload.site_statuses.size }.from(1).to(2)
        expect(new_site_status.status).to eq('running')
      end

      it 'sets the site to running when an existing site is added' do
        expect { subject.sites = [existing_site] }
          .to change { existing_site_status.reload.status }.from('suspended').to('running')
      end
    end

    context 'for courses without any training locations' do
      subject { create(:course, site_statuses: []) }

      it 'sets the site to new when a new site is added' do
        expect { subject.sites = [new_site] }.to change { subject.reload.site_statuses.size }.from(0).to(1)
        expect(new_site_status.status).to eq('new_status')
      end
    end
  end

  describe '#ratifying_provider_description' do
    subject { course.ratifying_provider_description }

    context 'for courses without ratifying provider' do
      let(:accrediting_provider) { nil }
      let(:course) { create(:course, accrediting_provider:) }

      it { is_expected.to be_nil }
    end

    context 'for courses with ratifying provider' do
      let(:provider) { create(:provider) }
      let(:accrediting_provider) { build(:accredited_provider) }
      let(:course) { create(:course, provider:, accrediting_provider:) }

      context 'without any provider partnership' do
        it { is_expected.to be_nil }
      end

      context 'with accrediting_provider_enrichments' do
        let(:provider) { create(:provider, accredited_partnerships: [build(:provider_partnership, accredited_provider: accrediting_provider, description: 'one two three')]) }

        it { is_expected.to match 'one two three' }
      end
    end
  end

  describe '#accrediting_provider_description' do
    subject { course.accrediting_provider_description }

    let(:accrediting_provider) { nil }
    let(:course) { create(:course, accrediting_provider:) }

    context 'for courses without accrediting provider' do
      it { is_expected.to be_nil }
    end

    context 'for courses with accrediting provider' do
      let(:accrediting_provider) { build(:provider) }
      let(:course) { create(:course, provider:, accrediting_provider:) }

      let(:provider) { build(:provider, accrediting_provider_enrichments:) }

      context 'without any accrediting_provider_enrichments' do
        let(:accrediting_provider_enrichments) { nil }

        it { is_expected.to be_nil }
      end

      context 'with accrediting_provider_enrichments' do
        let(:accrediting_provider_enrichment_description) { Faker::Lorem.sentence.to_s }
        let(:accrediting_provider_enrichment) do
          {
            'UcasProviderCode' => accrediting_provider.provider_code,
            'Description' => accrediting_provider_enrichment_description
          }
        end

        let(:accrediting_provider_enrichments) { [accrediting_provider_enrichment] }

        it { is_expected.to match accrediting_provider_enrichment_description }
      end
    end
  end

  describe '#enrichments' do
    describe '#find_or_initialize_draft' do
      copyable_enrichment_attributes =
        %w[
          about_course
          course_length
          fee_details
          fee_international
          fee_uk_eu
          financial_support
          how_school_placements_work
          interview_process
          other_requirements
          personal_qualities
          qualifications
          salary_details
        ].freeze

      subject { course.enrichments.find_or_initialize_draft }

      let(:course) { create(:course, enrichments:) }
      let(:actual_enrichment_attributes) do
        subject.attributes.slice(*copyable_enrichment_attributes)
      end

      context 'no enrichments' do
        let(:enrichments) { [] }

        it 'sets all attributes to be nil' do
          expect(actual_enrichment_attributes.values).to be_all(&:nil?)
        end

        its(:id) { is_expected.to be_nil }
        its(:last_published_timestamp_utc) { is_expected.to be_nil }
        its(:status) { is_expected.to eq 'draft' }
      end

      context 'with a draft enrichment' do
        let(:initial_draft_enrichment) { build(:course_enrichment, :initial_draft) }
        let(:enrichments) { [initial_draft_enrichment] }
        let(:expected_enrichment_attributes) { initial_draft_enrichment.attributes.slice(*copyable_enrichment_attributes) }

        it 'has all the same attributes as the initial draft enrichment' do
          expect(actual_enrichment_attributes).to eq expected_enrichment_attributes
        end

        its(:id) { is_expected.not_to be_nil }
        its(:last_published_timestamp_utc) { is_expected.to eq initial_draft_enrichment.last_published_timestamp_utc }
        its(:status) { is_expected.to eq 'draft' }
      end

      context 'with a published enrichment' do
        let(:published_enrichment) { build(:course_enrichment, :published) }
        let(:enrichments) { [published_enrichment] }
        let(:expected_enrichment_attributes) { published_enrichment.attributes.slice(*copyable_enrichment_attributes) }

        it 'has all the same attributes as the published enrichment' do
          expect(actual_enrichment_attributes).to eq expected_enrichment_attributes
        end

        its(:id) { is_expected.to be_nil }
        its(:last_published_timestamp_utc) { is_expected.to be_nil }
        its(:status) { is_expected.to eq 'draft' }
      end

      context 'with a draft and published enrichment' do
        let(:published_enrichment) { build(:course_enrichment, :published) }
        let(:subsequent_draft_enrichment) { build(:course_enrichment, :subsequent_draft) }
        let(:enrichments) { [published_enrichment, subsequent_draft_enrichment] }
        let(:expected_enrichment_attributes) { subsequent_draft_enrichment.attributes.slice(*copyable_enrichment_attributes) }

        it 'has all the same attributes as the subsequent draft enrichment' do
          expect(actual_enrichment_attributes).to eq expected_enrichment_attributes
        end

        its(:id) { is_expected.not_to be_nil }
        its(:last_published_timestamp_utc) { is_expected.to be_within(1.second).of subsequent_draft_enrichment.last_published_timestamp_utc }
        its(:status) { is_expected.to eq 'draft' }
      end
    end
  end

  describe 'self.get_by_codes' do
    it 'returns the found course' do
      expect(described_class.get_by_codes(
               course.recruitment_cycle.year,
               course.provider.provider_code,
               course.course_code
             )).to eq course
    end
  end

  describe 'next_recruitment_cycle?' do
    subject { course.next_recruitment_cycle? }

    context 'course is in current recruitment cycle' do
      it { is_expected.to be_falsey }
    end

    context 'course is in the next recruitment cycle' do
      let(:recruitment_cycle) { create(:recruitment_cycle, :next) }
      let(:provider)          { create(:provider, recruitment_cycle:) }
      let(:course) { create(:course, provider:) }

      it { is_expected.to be_truthy }
    end
  end

  describe '#discard' do
    context 'new course' do
      subject { course }

      let!(:course) do
        course = create(:course)

        site = create(:site)
        create(:site_status, :new_status, site:, course:)

        course
      end

      context 'before discarding' do
        its(:discarded?) { is_expected.to be false }

        it 'is in kept' do
          expect(described_class.kept.size).to eq(1)
        end

        it 'is not in discarded' do
          expect(described_class.discarded.size).to eq(0)
        end
      end

      context 'after discarding' do
        before do
          course.discard
        end

        its(:discarded?) { is_expected.to be true }

        it 'is not in kept' do
          expect(described_class.kept.size).to eq(0)
        end

        it 'is in discarded' do
          expect(described_class.discarded.size).to eq(1)
        end
      end

      context 'incorrect actions' do
        it 'raises error when deleted and course status is running' do
          course = subject

          site = create(:site)
          create(:site_status, :running, :published, site:, course:)

          expect { course.discard }.to raise_error(
            "You cannot delete the running course #{course}"
          )
        end
      end
    end
  end

  describe '#applications_open_from' do
    context 'a new course with a given date' do
      subject { create(:course, applications_open_from:) }

      let(:applications_open_from) { Time.zone.today }

      its(:applications_open_from) { is_expected.to eq applications_open_from }
    end

    context 'a new course within a recruitment cycle' do
      subject { create(:course, :applications_open_from_not_set, provider:) }

      let(:recruitment_cycle) { build(:recruitment_cycle, :next) }
      let(:provider)          { build(:provider, recruitment_cycle:) }

      its(:applications_open_from) { is_expected.to eq recruitment_cycle.application_start_date }
    end
  end

  describe '#is_send=' do
    subject { build(:course) }

    before do
      subject.is_send = value
    end

    context 'when value is `true`' do
      let(:value) { true }

      its(:is_send) { is_expected.to be(true) }
    end

    context 'when value is `"true"`' do
      let(:value) { 'true' }

      its(:is_send) { is_expected.to be(true) }
    end

    context 'when value is `1`' do
      let(:value) { 1 }

      its(:is_send) { is_expected.to be(true) }
    end

    context 'when value is `0`' do
      let(:value) { 0 }

      its(:is_send) { is_expected.to be(false) }
    end

    context 'when value is `false`' do
      let(:value) { false }

      its(:is_send) { is_expected.to be(false) }
    end

    context 'when value is `"false"`' do
      let(:value) { 'false' }

      its(:is_send) { is_expected.to be(false) }
    end
  end

  describe '#self_accredited?' do
    subject { create(:course, provider:) }

    context 'when self accredited' do
      let(:provider) { build(:provider, :accredited_provider) }

      its(:self_accredited?) { is_expected.to be_truthy }
    end

    context 'when not self accredited' do
      let(:provider) { build(:provider) }

      its(:self_accredited?) { is_expected.to be_falsey }
    end
  end

  describe '#course_params_assignable' do
    let(:is_admin) { false }

    describe 'when setting the entry requirement' do
      it 'can assign a valid value' do
        expect(course.course_params_assignable({ maths: 'equivalence_test' }, is_admin)).to be(true)
        expect(course.errors.messages).to eq({})
      end

      it 'cannot be assigned an invalid value' do
        expect(course.course_params_assignable({ maths: 'test' }, is_admin)).to be(false)
        expect(course.errors.messages).to eq(maths: ['is invalid'])
      end
    end

    describe 'when setting the qualification' do
      it 'can assign a valid qualification' do
        expect(course.course_params_assignable({ qualification: 'pgce_with_qts' }, is_admin)).to be(true)
        expect(course.errors.messages).to eq({})
      end

      it 'cannot assign invalid qualification' do
        expect(course.course_params_assignable({ qualification: 'invalid' }, is_admin)).to be(false)
        expect(course.errors.messages).to eq(qualification: ['is invalid'])
      end
    end

    describe 'for publishing' do
      context 'when not published' do
        let(:enrichment) { create(:course_enrichment, :initial_draft) }
        let(:course) { create(:course, enrichments: [enrichment]) }

        it 'can assign to SEND' do
          expect(course.course_params_assignable({ is_send: true }, is_admin)).to be(true)
          expect(course.errors.messages).to eq({})
        end

        it 'can assign to applications open from' do
          expect(course.course_params_assignable({ applications_open_from: '25/08/2019' }, is_admin)).to be(true)
          expect(course.errors.messages).to eq({})
        end

        it 'can assign to applications open from' do
          expect(course.course_params_assignable({ application_start_date: '25/08/2019' }, is_admin)).to be(true)
          expect(course.errors.messages).to eq({})
        end
      end

      context 'when published' do
        let(:enrichment) { create(:course_enrichment, :published) }
        let(:course) { create(:course, enrichments: [enrichment]) }

        it 'cannot assign to SEND' do
          expect(course.course_params_assignable({ is_send: true }, is_admin)).to be(false)
          expect(course.errors.messages).to eq(is_send: ['cannot be changed after publish'])
        end

        it 'cannot assign to applications open from' do
          expect(course.course_params_assignable({ applications_open_from: '25/08/2019' }, is_admin)).to be(false)
          expect(course.errors.messages).to eq(applications_open_from: ['cannot be changed after publish'])
        end

        it 'cannot assign to applications open from' do
          expect(course.course_params_assignable({ application_start_date: '25/08/2019' }, is_admin)).to be(false)
          expect(course.errors.messages).to eq(application_start_date: ['cannot be changed after publish'])
        end

        context 'is_admin is set to true' do
          let(:is_admin) { true }

          it 'can assign to SEND' do
            expect(course.course_params_assignable({ is_send: true }, is_admin)).to be(true)
            expect(course.errors.messages).to eq({})
          end
        end
      end
    end
  end

  describe '#is_published?' do
    context 'course is not published' do
      let(:enrichment) { create(:course_enrichment, :initial_draft) }
      let(:course) { create(:course, enrichments: [enrichment]) }

      it 'returns false' do
        expect(course.is_published?).to be(false)
      end
    end

    context 'course is published' do
      let(:enrichment) { create(:course_enrichment, :published) }
      let(:course) { create(:course, enrichments: [enrichment]) }

      it 'returns true' do
        expect(course.is_published?).to be(true)
      end
    end

    context 'course is published with unpublished changes' do
      let(:enrichment) { create(:course_enrichment, :subsequent_draft) }
      let(:course) { create(:course, enrichments: [enrichment]) }

      it 'returns true' do
        expect(course.content_status).to eq(:published_with_unpublished_changes)
        expect(course.is_published?).to be(true)
      end
    end

    context 'course is withdrawn' do
      let(:enrichment) { create(:course_enrichment, :withdrawn) }
      let(:course) { create(:course, enrichments: [enrichment]) }

      it 'returns false' do
        expect(course.content_status).to eq(:withdrawn)
        expect(course.is_published?).to be(false)
        expect(course.withdrawn_at).not_to be_nil
      end
    end
  end

  describe '#generate_name' do
    it 'Generates a name using the correct service' do
      expect(Courses::GenerateCourseNameService).to receive(:call).with(course:)
      course.generate_name
    end
  end

  describe '#assignable_master_subjects' do
    it 'Returns the master subjects using the correct service' do
      expect(course).to(
        delegate_method_to_service(
          :assignable_master_subjects,
          'Courses::AssignableMasterSubjectService'
        ).with_arguments(
          course:
        )
      )
    end
  end

  describe '#assignable_subjects' do
    it 'Returns the subjects using the correct service' do
      expect(course).to(
        delegate_method_to_service(
          :assignable_subjects,
          'Courses::AssignableSubjectService'
        ).with_arguments(
          course:
        )
      )
    end
  end

  describe '#subordinate_subject_id' do
    it 'has a subordinate_subject_id attribute' do
      expect(course).to have_attributes({ subordinate_subject_id: nil })
    end

    it 'is assignabled' do
      course.subordinate_subject_id = 123
      expect(course).to have_attributes({ subordinate_subject_id: 123 })
    end

    context 'when course has two subjects' do
      it 'set the subordinate subject id to the second subjects_id' do
        subordinate_subject = find_or_create(:secondary_subject, :physics)
        course.subjects << subordinate_subject
        expect(course.reload).to have_attributes({ subordinate_subject_id: subordinate_subject.id })
      end
    end
  end

  describe '#age_minimum' do
    context 'when age_range_in_years set' do
      it 'returns lower age_range_in_years bound' do
        expect(subject.age_minimum).to be(3)
      end
    end

    context 'when age_range_in_years not set' do
      subject { described_class.new }

      it 'returns nil' do
        expect(subject.age_minimum).to be_nil
      end
    end
  end

  describe '#age_maximum' do
    context 'when age_range_in_years set' do
      it 'returns upper age_range_in_years bound' do
        expect(subject.age_maximum).to be(7)
      end
    end

    context 'when age_range_in_years not set' do
      subject { described_class.new }

      it 'returns nil' do
        expect(subject.age_maximum).to be_nil
      end
    end
  end

  describe '#bursary_requirements' do
    context 'when there is no bursary' do
      subject do
        create(
          :course,
          level: 'primary',
          name: 'Primary with english',
          course_code: 'AAAA',
          subjects: [find_or_create(:primary_subject, :primary_with_english)]
        )
      end

      it 'returns no requirements' do
        expect(subject.bursary_requirements).to be_empty
      end
    end

    context 'when there is a bursary' do
      subject do
        create(
          :course,
          level: 'secondary',
          name: 'Classics',
          course_code: 'AAAA',
          subjects: [find_or_create(:secondary_subject, :classics)]
        )
      end

      it 'returns default requirements' do
        expect(subject.bursary_requirements).to eql(['a degree of 2:2 or above in any subject'])
      end
    end
  end

  describe 'rollable?' do
    subject do
      create(
        :course,
        level: 'secondary',
        name: 'Classics',
        course_code: 'AAAA',
        enrichments: [enrichment]
      ).rollable?
    end

    context 'course is published' do
      let(:enrichment) { create(:course_enrichment, :published) }

      it { is_expected.to be(true) }
    end

    context 'course is withdrawn' do
      let(:enrichment) { create(:course_enrichment, :withdrawn) }

      it { is_expected.to be(true) }
    end

    context 'course is published with unpublished changes' do
      let(:enrichment) { create(:course_enrichment, :subsequent_draft) }

      it { is_expected.to be(true) }
    end
  end

  describe 'update_changed_at' do
    around do |example|
      Timecop.freeze do
        example.run
      end
    end

    before do
      course.update_columns(changed_at: 1.day.ago)
      course.provider.update_columns(changed_at: 1.day.ago)
      course.update_changed_at
    end

    it 'sets changed_at' do
      expect(course.changed_at).to be_within(1.second).of(Time.zone.now)
    end

    it 'touches the provider' do
      expect(course.provider.changed_at).to be_within(1.second).of(Time.zone.now)
    end
  end

  describe '#degree_section_complete?' do
    context 'when degree_grade is set' do
      subject { build(:course, degree_grade: 'two_one') }

      it 'returns true' do
        expect(subject.degree_section_complete?).to be(true)
      end
    end

    context 'when degree_grade is nil' do
      subject { build(:course, degree_grade: nil) }

      it 'returns false' do
        expect(subject.degree_section_complete?).to be(false)
      end
    end
  end

  describe 'application_status enum' do
    subject(:course) do
      create(
        :course,
        level: 'secondary',
        name: 'Biology',
        course_code: '3X9F',
        subjects: [find_or_create(:secondary_subject, :biology)]
      )
    end

    context 'default' do
      it 'sets the value as closed' do
        expect(course.application_status).to eq('closed')
      end
    end

    context 'open course' do
      it 'sets the value as open' do
        course.application_status_open!
        expect(course.reload.application_status).to eq('open')
      end
    end

    context 'closed course' do
      it 'resets the value as closed' do
        course.application_status_closed!
        expect(course.reload.application_status).to eq('closed')
      end
    end
  end

  describe 'degree_type enum' do
    subject(:course) { create(:course) }

    context 'default' do
      it 'sets the value as postgraduate' do
        expect(course.degree_type).to eq('postgraduate')
      end
    end

    context 'undergraduate course' do
      it 'sets the value to undergraduate' do
        course.undergraduate_degree_type!
        expect(course.reload.degree_type).to eq('undergraduate')
      end
    end

    context 'postgraduate course' do
      it 'sets the value to postgraduate' do
        course.postgraduate_degree_type!
        expect(course.reload.degree_type).to eq('postgraduate')
      end
    end

    context 'validation' do
      it 'raises an error when setting an invalid degree_type' do
        expect { course.update!(degree_type: 'invalid') }.to raise_error(ArgumentError)
      end
    end

    context 'predicate methods' do
      it 'returns true for postgraduate?' do
        expect(course.postgraduate_degree_type?).to be true
      end

      it 'returns false for undergraduate?' do
        expect(course.undergraduate_degree_type?).to be false
      end

      it 'returns true for undergraduate? after setting to undergraduate' do
        course.undergraduate_degree_type!
        expect(course.undergraduate_degree_type?).to be true
      end
    end
  end

  describe 'funding enum' do
    subject(:course) { create(:course) }

    context 'fee funding' do
      it 'sets the value to fee' do
        course.fee!
        expect(course.reload.funding).to eq('fee')
      end
    end

    context 'salary funding' do
      it 'sets the value to salary' do
        course.salary!
        expect(course.reload.funding).to eq('salary')
      end
    end

    context 'apprenticeship funding' do
      it 'sets the value to apprenticeship' do
        course.apprenticeship!
        expect(course.reload.funding).to eq('apprenticeship')
      end
    end

    context 'validation' do
      it 'raises an error when setting an invalid funding' do
        expect { course.update!(funding: 'invalid') }.to raise_error(ArgumentError)
      end
    end

    context 'predicate methods' do
      it 'returns false for fee?' do
        expect(course.fee?).to be true
      end

      it 'returns false for salary?' do
        expect(course.salary?).to be false
      end

      it 'returns true for salary? after setting to salary' do
        course.salary!
        expect(course.salary?).to be true
      end

      it 'returns true for apprenticeship? after setting to apprenticeship' do
        course.apprenticeship!
        expect(course.apprenticeship?).to be true
      end
    end
  end

  describe '#is_primary?' do
    context 'when course is primary' do
      subject { build(:course, level: :primary) }

      it 'returns true' do
        expect(subject.is_primary?).to be(true)
      end
    end

    context 'when course is not primary' do
      subject { build(:course, level: :secondary) }

      it 'returns false' do
        expect(subject.is_primary?).to be(false)
      end
    end
  end

  describe '#academic_year' do
    context 'when the course has a September 2021 start date' do
      subject { build(:course, start_date:) }

      let(:start_date) { Date.new(2021, 9, 1) }

      it "returns the course's academic year" do
        expect(subject.academic_year).to eq('2021 to 2022')
      end
    end

    context 'when the course has a December 2021 start date' do
      subject { build(:course, start_date:) }

      let(:start_date) { Date.new(2021, 12, 1) }

      it "returns the course's academic year" do
        expect(subject.academic_year).to eq('2021 to 2022')
      end
    end

    context 'when the course has a January 2022 start date' do
      subject { build(:course, start_date:) }

      let(:start_date) { Date.new(2022, 1, 1) }

      it "returns the course's academic year" do
        expect(subject.academic_year).to eq('2021 to 2022')
      end
    end

    context 'when the course has a January 2023 start date' do
      subject { build(:course, start_date:) }

      let(:start_date) { Date.new(2023, 1, 1) }

      it "returns the course's academic year" do
        expect(subject.academic_year).to eq('2022 to 2023')
      end
    end

    context 'when the course has an August 2023 start date' do
      subject { build(:course, start_date:) }

      let(:start_date) { Date.new(2023, 8, 1) }

      it "returns the course's academic year" do
        expect(subject.academic_year).to eq('2022 to 2023')
      end
    end
  end

  describe '#funding_type' do
    context 'deprecation warning' do
      it 'issues a deprecation warning when `funding_type` is called' do
        deprecation_instance = instance_double(ActiveSupport::Deprecation)
        allow(ActiveSupport::Deprecation).to receive(:new).and_return(deprecation_instance)
        expect(deprecation_instance).to receive(:warn).with(
          '`funding_type` is deprecated and will be removed. Please use `funding` instead.'
        )

        course = described_class.new
        course.funding_type
      end
    end

    context 'when funding is set to fee on a salaried program' do
      it 'returns fee' do
        course = described_class.new(program_type: :higher_education_salaried_programme, funding: 'fee')
        expect(course.program_type).to eq('higher_education_salaried_programme')
        expect(course.funding).to eq('fee')
      end
    end

    context 'when funding is set to salary on a fee program' do
      it 'returns salary' do
        course = build(:course, :with_school_direct, funding: 'salary')
        expect(course.program_type).to eq('school_direct_training_programme')
        expect(course.funding).to eq('salary')
      end
    end

    context 'when funding is set to fee on a fee program' do
      it 'returns fee' do
        course = build(:course, :with_school_direct, funding: 'fee')
        expect(course.program_type).to eq('school_direct_training_programme')
        expect(course.funding).to eq('fee')
      end
    end

    context 'when funding is set to apprenticeship on a fee program' do
      it 'returns apprenticeship' do
        course = build(:course, :with_school_direct, funding: 'apprenticeship')
        expect(course.program_type).to eq('school_direct_training_programme')
        expect(course.funding).to eq('apprenticeship')
      end
    end

    context 'when funding is set to fee on a apprenticeship program' do
      it 'returns fee' do
        course = build(:course, :with_apprenticeship, funding: 'fee')
        expect(course.program_type).to eq('pg_teaching_apprenticeship')
        expect(course.funding).to eq('fee')
      end
    end
  end

  describe '#program' do
    context 'when program_type is nil' do
      it 'returns nil' do
        course = build(:course, program_type: nil)

        expect(course.program).to be(UnknownProgramme)
      end
    end

    context 'when program_type is higher_education_programme' do
      it 'returns the HigherEducationProgramme' do
        course = build(:course, program_type: :higher_education_programme)

        expect(course.program).to be(HigherEducationProgramme)
      end
    end
  end

  describe '#ensure_site_statuses_match_full_time' do
    it 'updates all site statuses to full_time_vacancies' do
      course = create(:course, study_mode: :part_time)
      site_status_part_time = create(:site_status, course:, vac_status: :part_time_vacancies)

      course.study_mode = 'full_time'
      course.ensure_site_statuses_match_full_time

      course.reload
      site_status_part_time.reload

      expect(site_status_part_time.vac_status).to eq('full_time_vacancies')
      expect(course.site_statuses.map(&:vac_status).first).to eq('full_time_vacancies')
    end
  end

  describe '#last_published_at' do
    context 'with an unpublished course' do
      let(:course) { create(:course, study_mode: :part_time, enrichments: [create(:course_enrichment)]) }

      it 'returns nil' do
        expect(course.last_published_at).to be_nil
      end
    end

    context 'with a twice published course' do
      let(:course) do
        create(:course, study_mode: :part_time, enrichments:
          [
            create(:course_enrichment, :published, last_published_timestamp_utc: '1/1/2024'),
            create(:course_enrichment, :published, last_published_timestamp_utc: '1/1/2023')
          ])
      end

      it 'selects the enrichment with the latest date' do
        expect(course.last_published_at).to eq('1/1/2024')
      end

      context 'when the enrichments are not loaded' do
        it 'selects the enrichment with the latest date' do
          course.reload
          expect(course.enrichments.loaded?).to be_falsey
          expect(course.last_published_at).to eq('1/1/2024')
        end
      end
    end
  end

  describe 'funding_type and program_type' do
    context 'setting the funding to apprenticeship' do
      it 'sets the funding to apprenticeship and program_type to pg_teaching_apprenticeship' do
        course = build(:course, funding: 'apprenticeship')

        expect(course.funding).to eq('apprenticeship')
        expect(course.program_type).to eq('pg_teaching_apprenticeship')
      end
    end

    context 'setting the funding to salary' do
      context 'when the provider is a SCITT' do
        it 'sets the funding to salary and the program_type to scitt_salaried_programme' do
          provider = build(:provider, provider_type: 'scitt')
          course = create(:course, provider:, funding: 'salary')

          expect(course.funding).to eq('salary')
          expect(course.program_type).to eq('scitt_salaried_programme')
        end
      end

      context 'when the provider is a University' do
        it 'sets the funding to salary and the program_type to higher_education_salaried_programme' do
          provider = build(:provider, provider_type: 'university')
          course = create(:course, provider:, funding: 'salary')

          expect(course.funding).to eq('salary')
          expect(course.program_type).to eq('higher_education_salaried_programme')
        end
      end

      context 'when the provider is a Lead School' do
        it 'sets the funding to salary and the program_type to school_direct_salaried_training_programme' do
          provider = build(:provider, provider_type: 'lead_school')
          course = create(:course, provider:, funding: 'salary')

          expect(course.funding).to eq('salary')
          expect(course.program_type).to eq('school_direct_salaried_training_programme')
        end
      end
    end

    describe '#update_program_type!' do
      context 'when the provider is a Lead School' do
        context 'changing funding from fee to apprenticeship' do
          it 'changes the program_type from school_direct_training_programme to pg_teaching_apprenticeship' do
            course = build(:course, program_type: 'school_direct_training_programme')

            expect(course.program_type).to eq('school_direct_training_programme')

            course.update(funding: 'apprenticeship')
            expect(course.program_type).to eq('pg_teaching_apprenticeship')
          end
        end

        context 'changing funding from fee to salary' do
          it 'changes the program_type from school_direct_training_programme to school_direct_salaried_training_programme' do
            course = build(:course, program_type: 'school_direct_training_programme')

            expect(course.program_type).to eq('school_direct_training_programme')

            course.update(funding: 'salary')
            expect(course.program_type).to eq('school_direct_salaried_training_programme')
          end
        end

        context 'changing funding from salary to fee' do
          it 'changes the program_type from school_direct_training_programme to school_direct_salaried_training_programme' do
            course = build(:course, program_type: 'school_direct_salaried_training_programme')

            expect(course.program_type).to eq('school_direct_salaried_training_programme')

            course.update(funding: 'fee')
            expect(course.program_type).to eq('school_direct_training_programme')
          end
        end
      end

      context 'when the provider is a scitt' do
        context 'changing funding from fee to salary' do
          it 'changes the program_type from scitt_program to scitt_salaried_programme' do
            provider = build(:provider, provider_type: 'scitt')
            course = build(:course, provider:, program_type: 'scitt_programme')

            expect(course.program_type).to eq('scitt_programme')

            course.update(funding: 'salary')
            expect(course.program_type).to eq('scitt_salaried_programme')
          end
        end

        context 'changing funding from salary to fee' do
          it 'changes the program_type from scitt_salaried_programme to scitt_programme' do
            provider = build(:provider, provider_type: 'scitt')
            course = build(:course, provider:, program_type: 'scitt_salaried_programme')

            expect(course.program_type).to eq('scitt_salaried_programme')

            course.update(funding: 'fee')
            expect(course.program_type).to eq('scitt_programme')
          end
        end
      end

      context 'when the provider is a HEI' do
        context 'changing funding from fee to salary' do
          it 'changes the program_type from higher_education_programme to higher_education_salaried_programme' do
            provider = build(:provider, provider_type: 'university')
            course = build(:course, provider:, program_type: 'higher_education_programme')

            expect(course.program_type).to eq('higher_education_programme')

            course.update(funding: 'salary')
            expect(course.program_type).to eq('higher_education_salaried_programme')
          end
        end

        context 'changing funding from fee to salaried' do
          it 'changes the program_type from higher_education_salaried_programme to higher_education_programme' do
            provider = build(:provider, provider_type: 'university')
            course = build(:course, provider:, program_type: 'higher_education_salaried_programme')

            expect(course.program_type).to eq('higher_education_salaried_programme')

            course.update(funding: 'fee')
            expect(course.program_type).to eq('higher_education_programme')
          end
        end
      end
    end

    context 'setting the funding to fee' do
      context 'when the provider is not self accredited' do
        it 'sets the funding to salary and the program_type to school_direct_training_programme' do
          provider = build(:provider)
          course = create(:course, provider:, funding: 'fee')

          expect(course.funding).to eq('fee')
          expect(course.program_type).to eq('school_direct_training_programme')
        end
      end

      context 'when the provider is self accredited and a SCITT' do
        it 'sets the funding to salary and the program_type to scitt_programme' do
          provider = build(:accredited_provider, :scitt)
          course = create(:course, provider:, funding: 'fee')

          expect(course.funding).to eq('fee')
          expect(course.program_type).to eq('scitt_programme')
        end
      end

      context 'when the provider is self accredited and not a SCITT' do
        it 'sets the funding to salary and the program_type to higher_education_programme' do
          provider = build(:accredited_provider, :university)
          course = create(:course, provider:, funding: 'fee')

          expect(course.funding).to eq('fee')
          expect(course.program_type).to eq('higher_education_programme')
        end
      end
    end
  end

  describe '#any_a_levels?' do
    it 'returns false if no a levels' do
      course = build(:course)

      expect(course.any_a_levels?).to be_falsy
    end

    context 'when a_level_subject_requirements is present' do
      it 'returns true' do
        course = build(
          :course,
          a_level_subject_requirements: [{ uuid: SecureRandom.uuid, subject: 'any_subject', minimum_grade_required: 'A' }]
        )

        expect(course.any_a_levels?).to be_truthy
      end
    end

    context 'when accept_pending_a_level is present' do
      it 'returns true' do
        course = build(
          :course,
          accept_pending_a_level: true
        )

        expect(course.any_a_levels?).to be_truthy
      end
    end

    context 'when accept_a_level_equivalency is present' do
      it 'returns true' do
        course = build(
          :course,
          accept_a_level_equivalency: true
        )

        expect(course.any_a_levels?).to be_truthy
      end
    end

    context 'when additional_a_level_equivalencies is present' do
      it 'returns true' do
        course = build(
          :course,
          additional_a_level_equivalencies: 'Can you juggle?'
        )

        expect(course.any_a_levels?).to be_truthy
      end
    end
  end

  describe '#training_route' do
    it 'returns teacher_degree_apprenticeship for undergraduate and apprenticeship' do
      course = build(:course, funding: 'apprenticeship', degree_type: 'undergraduate')
      expect(course.training_route).to eq('teacher_degree_apprenticeship')
    end

    it 'returns school_direct_salaried for postgraduate and salaried' do
      course = build(:course, funding: 'salary', degree_type: 'postgraduate')
      expect(course.training_route).to eq('school_direct_salaried')
    end

    it 'returns postgraduate_teaching_apprenticeship for postgraduate and apprenticeship' do
      course = build(:course, funding: 'apprenticeship', degree_type: 'postgraduate')
      expect(course.training_route).to eq('postgraduate_teacher_apprenticeship')
    end

    it 'returns fee_funded_initial_teacher_training for postgraduate and fee' do
      course = build(:course, funding: 'fee', degree_type: 'postgraduate')
      expect(course.training_route).to eq('fee_funded_initial_teacher_training')
    end

    it 'returns unknown_training_route for unknown degree_type and funding combination' do
      course = build(:course, funding: 'fee', degree_type: 'undergraduate')
      expect(course.training_route).to eq('unknown_training_route')
    end
  end

  describe '#visa_sponsorship' do
    context 'when the funding type is fee-based' do
      let(:course) { build(:course, funding: 'fee', can_sponsor_student_visa:) }

      context 'and the course can sponsor a student visa' do
        let(:can_sponsor_student_visa) { true }

        it 'returns :can_sponsor_student_visa' do
          expect(course.visa_sponsorship).to eq(:can_sponsor_student_visa)
        end
      end

      context 'and the course cannot sponsor a student visa' do
        let(:can_sponsor_student_visa) { false }

        it 'returns :no_sponsorship' do
          expect(course.visa_sponsorship).to eq(:no_sponsorship)
        end
      end
    end

    context 'when the funding type is salary-based or apprenticeship' do
      let(:course) { build(:course, funding: funding, can_sponsor_skilled_worker_visa:) }

      %w[salary apprenticeship].each do |funding_type|
        context "and the funding type is #{funding_type}" do
          let(:funding) { funding_type }

          context 'and the course can sponsor a skilled worker visa' do
            let(:can_sponsor_skilled_worker_visa) { true }

            it 'returns :can_sponsor_skilled_worker_visa' do
              expect(course.visa_sponsorship).to eq(:can_sponsor_skilled_worker_visa)
            end
          end

          context 'and the course cannot sponsor a skilled worker visa' do
            let(:can_sponsor_skilled_worker_visa) { false }

            it 'returns :no_sponsorship' do
              expect(course.visa_sponsorship).to eq(:no_sponsorship)
            end
          end
        end
      end
    end
  end
end
