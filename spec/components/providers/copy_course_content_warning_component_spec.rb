# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Providers::CopyCourseContentWarningComponent do
  alias_method :component, :page

  context 'without copied fields' do
    it 'does not render anything' do
      render_inline(described_class.new([], 'form-identifier', build(:course)))

      expect(component.text).to eq ''
    end
  end

  context 'with just one copied field' do
    it 'renders singular text' do
      copied_fields = [['How placements work', 'how_placements_work']]
      source_course = build(:course)
      render_inline(described_class.new(copied_fields, 'form-identifier', source_course))

      expect(component).to have_content 'Your changes are not yet saved'
      expect(component).to have_content 'Please check it and make your changes before saving'
      expect(component).to have_content "We have copied this field from #{source_course.name} (#{source_course.course_code})"
      expect(component.find_link('How placements work')[:href]).to eq '#form-identifier-how-placements-work-field'
    end
  end

  context 'with more than one copied field' do
    it 'renders plural text' do
      copied_fields = [
        ['How placements work', 'how_placements_work'],
        ['About this course', 'about_this_course']
      ]
      source_course = build(:course)
      render_inline(described_class.new(copied_fields, 'form-identifier', source_course))

      expect(component).to have_content 'Your changes are not yet saved'
      expect(component).to have_content 'Please check them and make your changes before saving'
      expect(component).to have_content "We have copied these fields from #{source_course.name} (#{source_course.course_code})"
      expect(component.find_link('How placements work')[:href]).to eq '#form-identifier-how-placements-work-field'
      expect(component.find_link('About this course')[:href]).to eq '#form-identifier-about-this-course-field'
    end
  end
end
