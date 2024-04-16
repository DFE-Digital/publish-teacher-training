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

    it 'tells candidates sponsorship is not available' do
      expect(page).to have_text('Sponsorship for a student visa is not available for this course')
    end

    it 'renders the h3 qualifications gained outside the UK' do
      expect(page).to have_css('h3', text: 'Qualifications gained outside the UK')
    end

    it 'tells candidates about qualifications gained outside of the UK' do
      expect(page).to have_text('If you studied for your qualifications outside of the UK you should apply for a statement of comparability from UK European Network of Information Centres (UK ENIC). This will show us how your qualifications compare to UK qualifications.')
    end

    it 'renders the enic link' do
      expect(page).to have_link('Apply for a statement of comparability (opens in new tab)')
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
      expect(page).to have_text('Before you apply for this course, contact us to check Student visa sponsorship is available. If it is, and you get a place on this course, we’ll help you apply for your visa.')
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
      render_inline(described_class.new(course: CourseDecorator.new(course)))
    end

    it 'tells candidates they’ll need the right to work' do
      expect(page).to have_text('You’ll need the right to work in the UK')
    end

    it 'tells candidates visa sponsorship may be available, but they should check' do
      expect(page).to have_text('Before you apply for this course, contact us to check Skilled Worker visa sponsorship is available. If it is, and you get a place on this course, we’ll help you apply for your visa.')
    end
  end

  context 'when the course is salaried and does not sponsor Skilled Worker visas' do
    before do
      course = build(
        :course,
        funding_type: 'salary',
        can_sponsor_skilled_worker_visa: false
      )
      render_inline(described_class.new(course: CourseDecorator.new(course)))
    end

    it 'tells candidates they’ll need the right to work' do
      expect(page).to have_text('You’ll need the right to work in the UK')
    end

    it 'tells candidates visa sponsorship is not available' do
      expect(page).to have_text('Sponsorship for a Skilled Worker visa is not available for this course')
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
