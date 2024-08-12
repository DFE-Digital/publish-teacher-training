# frozen_string_literal: true

require 'rails_helper'

describe Find::Courses::InternationalStudentsComponent::View, type: :component do
  context 'when the course is fee-paying and does not sponsor Student visas' do
    before do
      course = build(
        :course,
        funding_type: 'fee',
        can_sponsor_student_visa: false
      )
      render_inline(described_class.new(course: CourseDecorator.new(course)))
    end

    it 'tells candidates they’ll need the right to study' do
      expect(page).to have_text('You’ll need the right to study in the UK')
    end
  end

  context 'when the course is fee-paying and does sponsor Student visas' do
    before do
      course = build(
        :course,
        funding_type: 'fee',
        can_sponsor_student_visa: true
      )
      render_inline(described_class.new(course: CourseDecorator.new(course)))
    end

    it 'tells candidates they’ll need the right to study' do
      expect(page).to have_text('You’ll need the right to study in the UK')
    end

    it 'tells candidates visa sponsorship may be available, but they should check' do
      expect(page).to have_text('Before you apply for this course, contact the training provider to check Student visa sponsorship is available. If it is, and you get a place on this course, we’ll help you apply for your visa.')
    end

    it 'does not tell candidates the 3-year residency rule' do
      expect(page).to have_no_text('To apply for this teaching apprenticeship course, you’ll need to have lived in the UK for at least 3 years before the start of the course')
    end

    it 'does not tell candidates about settled and pre-settled status' do
      expect(page).to have_no_text('EEA nationals with settled or pre-settled status under the')
    end
  end

  context 'when the course is salaried and can sponsor Skilled Worker visas' do
    before do
      course = build(
        :course,
        funding_type: 'salary',
        can_sponsor_skilled_worker_visa: true
      )
      allow(Settings.features).to receive(:db_backed_funding_type).and_return(false)
      render_inline(described_class.new(course: CourseDecorator.new(course)))
    end

    it 'tells candidates they’ll need the right to work' do
      expect(page).to have_text('You’ll need the right to work in the UK')
    end

    it 'tells candidates visa sponsorship may be available, but they should check' do
      expect(page).to have_text('Before you apply for this course, contact the training provider to check Skilled Worker visa sponsorship is available. If it is, and you get a place on this course, we’ll help you apply for your visa.')
    end
  end

  context 'when the course is salaried and does not sponsor Skilled Worker visas' do
    before do
      course = build(
        :course,
        funding_type: 'salary',
        can_sponsor_skilled_worker_visa: false
      )
      allow(Settings.features).to receive(:db_backed_funding_type).and_return(false)
      render_inline(described_class.new(course: CourseDecorator.new(course)))
    end

    it 'tells candidates they’ll need the right to work' do
      expect(page).to have_text('You’ll need the right to work in the UK')
    end

    it 'does not tell candidates the 3-year residency rule' do
      expect(page).to have_no_text('To apply for this teaching apprenticeship course, you’ll need to have lived in the UK for at least 3 years before the start of the course')
    end

    it 'does not tell candidates about settled and pre-settled status' do
      expect(page).to have_no_text('EEA nationals with settled or pre-settled status under the')
    end
  end

  context 'when the course is an apprenticeship' do
    before do
      course = build(
        :course,
        funding_type: 'apprenticeship'
      )
      allow(Settings.features).to receive(:db_backed_funding_type).and_return(false)
      render_inline(described_class.new(course: CourseDecorator.new(course)))
    end

    it 'tells candidates the 3-year residency rule' do
      expect(page).to have_text('To apply for this teaching apprenticeship course, you’ll need to have lived in the UK for at least 3 years before the start of the course')
    end

    it 'tells candidates about settled and pre-settled status' do
      expect(page).to have_text('EEA nationals with settled or pre-settled status under the')
    end
  end
end
