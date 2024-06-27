# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ALevelRowComponent do
  it 'renders the a_level_not_required_content when a level requirements are not present' do
    course = create(:course, a_level_requirements: false)
    component = described_class.new(course: course.decorate)
    rendered_component = render_inline(component)

    expect(rendered_component.text).to include(I18n.t('publish.providers.courses.description_content.a_levels_not_required'))
  end

  it 'renders the a_level_subject_row_content when a level requirements and subject requirements are present' do
    a_level_subject_requirement = { 'subject' => 'other_subject', 'other_subject' => 'Math', 'minimum_grade_required' => 'A' }
    course = create(:course, a_level_requirements: true, a_level_subject_requirements: [a_level_subject_requirement])
    component = described_class.new(course: course.decorate)
    rendered_component = render_inline(component)

    expect(rendered_component.text).to include('Math - Grade A or above')
  end

  it 'renders the pending a level summary content for acceptance when course accepts pending a levels' do
    course = create(:course, accept_pending_a_level: true, a_level_requirements: true)
    component = described_class.new(course: course.decorate)
    rendered_component = render_inline(component)

    expect(rendered_component.text).to include(I18n.t('course.consider_pending_a_level.row.true'))
  end

  it 'renders the pending a level summary content for non-acceptance when course does not accept pending a levels' do
    course = create(:course, accept_pending_a_level: false, a_level_requirements: true)
    component = described_class.new(course: course.decorate)
    rendered_component = render_inline(component)

    expect(rendered_component.text).to include(I18n.t('course.consider_pending_a_level.row.false'))
  end

  it 'renders the a level equivalency summary content for acceptance when course accepts a level equivalencies' do
    course = create(:course, accept_a_level_equivalency: true, a_level_requirements: true)
    component = described_class.new(course: course.decorate)
    rendered_component = render_inline(component)

    expect(rendered_component.text).to include(I18n.t('course.a_level_equivalencies.row.true'))
  end

  it 'renders the a level equivalency summary content for non-acceptance when course does not accept a level equivalencies' do
    course = create(:course, accept_a_level_equivalency: false, a_level_requirements: true)
    component = described_class.new(course: course.decorate)
    rendered_component = render_inline(component)

    expect(rendered_component.text).to include(I18n.t('course.a_level_equivalencies.row.false'))
  end

  it 'renders the additional a level equivalencies content when present' do
    course = create(:course, accept_a_level_equivalency: true, additional_a_level_equivalencies: 'Some additional information', a_level_requirements: true)
    component = described_class.new(course: course.decorate)
    rendered_component = render_inline(component)

    expect(rendered_component.text).to include('Some additional information')
  end

  it 'does not render the additional a level equivalencies when no equivalencies' do
    course = create(:course, accept_a_level_equivalency: false, additional_a_level_equivalencies: 'Some additional information', a_level_requirements: true)
    component = described_class.new(course: course.decorate)
    rendered_component = render_inline(component)

    expect(rendered_component.text).not_to include('Some additional information')
  end

  it 'returns false for has_errors?' do
    course = create(:course)
    component = described_class.new(course: course.decorate)

    expect(component.has_errors?).to be(false)
  end
end
