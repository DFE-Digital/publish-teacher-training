# frozen_string_literal: true

require 'rails_helper'

describe Courses::AssignSubjectsService do
  subject do
    described_class.call(
      course:,
      subject_ids:
    )
  end

  context 'duplicated subject' do
    let(:course) { Course.new }
    let(:primary_subject) { find_or_create(:primary_subject, :primary) }
    let(:subject_ids) { [primary_subject.id, primary_subject.id] }

    it 'have duplicated subject errors' do
      expect(subject.errors[:subjects].first).to include('^The second subject must be different to the first subject')
    end
  end

  context 'no subject' do
    let(:course) { create(:course) }
    let(:subject_ids) { [] }

    it 'have creation subject errors' do
      expect(subject.errors[:subjects].first).to include('^Select a subject')
    end

    it 'have not updated course name' do
      expect { subject }
        .to not_change(course, :name)
    end
  end

  describe 'subordinate subject present but master missing' do
    let(:subject_ids) { [] }

    context 'with a new course' do
      let(:course) { Course.new }

      it 'raises missing subject error' do
        expect(subject.errors.full_messages).to include('Select a subject')
      end
    end

    context 'with a persisted course' do
      let(:course) { create(:course) }

      it 'raises missing subject error' do
        expect(subject.errors.full_messages).to include('Select a subject')
      end
    end
  end

  context 'primary course' do
    let(:subject_ids) { [primary_subject.id] }
    let(:course) { Course.new(level: :primary) }
    let(:primary_subject) { find_or_create(:primary_subject, :primary) }

    it 'sets the subjects' do
      expect(subject.course_subjects.map { _1.subject.id }).to eq(subject_ids)
    end

    it 'sets the name' do
      expect(subject.name).to eq('Primary')
    end

    it 'does not have errors' do
      expect(subject.errors).to be_empty
    end
  end

  context 'secondary course' do
    let(:subject_ids) { [secondary_subject.id] }
    let(:course) { Course.new(level: :secondary) }
    let(:secondary_subject) { find_or_create(:secondary_subject, :biology) }

    it 'sets the subjects' do
      expect(subject.course_subjects.map { _1.subject.id }).to eq([secondary_subject.id])
    end

    it 'sets the name' do
      expect(subject.name).to eq('Biology')
    end

    it 'does not have errors' do
      expect(subject.errors).to be_empty
    end

    context 'with 2 subjects' do
      let(:secondary_subject2) { find_or_create(:secondary_subject, :english) }
      let(:subject_ids) { [secondary_subject2.id, secondary_subject.id] }

      it 'sets the subjects' do
        expect(subject.course_subjects.map { _1.subject.id }).to eq(subject_ids)
      end

      it 'sets the course subjects position' do
        expect(subject.course_subjects.first.position).to eq(0)
        expect(subject.course_subjects.first.subject.id).to eq(secondary_subject2.id)

        expect(subject.course_subjects.second.position).to eq(1)
        expect(subject.course_subjects.second.subject.id).to eq(secondary_subject.id)
      end

      it 'sets the name' do
        expect(subject.name).to eq('English with biology')
      end
    end

    context 'with 3 subjects' do
      let(:secondary_english) { find_or_create(:secondary_subject, :english) }
      let(:language_subject) { find_or_create(:modern_languages_subject, :german) }
      let(:subject_ids) { [secondary_english.id, secondary_subject.id, language_subject.id] }

      it 'sets the subjects' do
        expect(subject.course_subjects.map { _1.subject.id }).to eq(subject_ids)
      end

      it 'sets the course subjects position' do
        expect(subject.course_subjects.first.position).to eq(0)
        expect(subject.course_subjects.first.subject.id).to eq(secondary_english.id)

        expect(subject.course_subjects.second.position).to eq(1)
        expect(subject.course_subjects.second.subject.id).to eq(secondary_subject.id)
      end

      it 'sets the name' do
        expect(subject.name).to eq('English with biology')
      end
    end
  end

  context 'further_education course' do
    let(:subject_ids) { nil }
    let(:course) { Course.new(level: :further_education, provider: Provider.new) }
    let(:further_education_subject) { find_or_create(:further_education_subject) }

    it 'sets the subjects' do
      expect(subject.course_subjects.map { _1.subject.id }).to eq([further_education_subject.id])
    end

    it 'sets the name' do
      expect(subject.name).to eq('Further education')
    end

    it 'sets further_education_fields' do
      expect(subject.funding_type).to eq('fee')
      expect(subject.english).to eq('not_required')
      expect(subject.maths).to eq('not_required')
      expect(subject.science).to eq('not_required')
    end
  end
end
