# frozen_string_literal: true

require 'rails_helper'

describe Find::Courses::ContentsComponent::View, type: :component do
  context 'when the program type is higher_education_programme' do
    it 'renders the schools section link' do
      provider = build(:provider)

      course = build(
        :course,
        provider:,
        program_type: 'higher_education_programme'
      ).decorate

      result = render_inline(described_class.new(course))

      expect(result.text).to include('How school placements work')
    end
  end

  context 'when the program type is scitt_programme' do
    it 'renders the schools section link' do
      provider = build(:provider)

      course = build(
        :course,
        provider:,
        program_type: 'scitt_programme'
      ).decorate

      result = render_inline(described_class.new(course))

      expect(result.text).to include('How school placements work')
    end
  end

  context 'when the program type neither one of higher education or scitt_progamme' do
    it 'does not render the school section link' do
      provider = build(:provider)

      course = build(
        :course,
        provider:
      ).decorate

      result = render_inline(described_class.new(course))

      expect(result.text).not_to include('How school placements work')
    end
  end

  context 'when the course is open' do
    it 'does render the apply link' do
      provider = build(:provider)
      course = build(:course, :open, provider:).decorate
      result = render_inline(described_class.new(course))

      expect(result.text).to include('Apply')
    end
  end

  context 'when the course is not open' do
    it 'does not render the apply link' do
      provider = build(:provider)
      course = build(:course, :closed, provider:).decorate

      result = render_inline(described_class.new(course))

      expect(result.text).not_to include('Apply')
    end
  end
end
