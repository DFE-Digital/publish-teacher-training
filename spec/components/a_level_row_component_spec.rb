# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ALevelRowComponent do
  include Rails.application.routes.url_helpers

  let(:a_level_subject_requirement) do
    { 'subject' => 'other_subject', 'other_subject' => 'Math', 'minimum_grade_required' => 'A' }
  end

  it 'renders the a_level_not_required_content when a level requirements are not present' do
    course = create(:course, a_level_requirements: false)
    component = described_class.new(course: course.decorate)
    rendered_component = render_inline(component)

    expect(rendered_component.text).to include(I18n.t('publish.providers.courses.description_content.a_levels_not_required'))
  end

  it 'does render to enter A levels when not A levels are answered' do
    course = create(:course, a_level_requirements: nil)
    component = described_class.new(course: course.decorate)
    rendered_component = render_inline(component)

    expect(rendered_component.text).to include(I18n.t('publish.providers.courses.description_content.enter_a_levels'))
  end

  it 'does render to enter A levels when not A level subjects are answered' do
    course = create(:course, a_level_requirements: true)
    component = described_class.new(course: course.decorate)
    rendered_component = render_inline(component)

    expect(rendered_component.text).to include(I18n.t('publish.providers.courses.description_content.enter_a_levels'))
  end

  it 'renders the a_level_subject_row_content when a level requirements and subject requirements are present' do
    a_level_subject_requirement = { 'subject' => 'other_subject', 'other_subject' => 'Math', 'minimum_grade_required' => 'A' }
    course = create(:course, a_level_requirements: true, a_level_subject_requirements: [a_level_subject_requirement])
    component = described_class.new(course: course.decorate)
    rendered_component = render_inline(component)

    expect(rendered_component.text).to include('Math - Grade A or above')
  end

  it 'renders the pending a level summary content for acceptance when course accepts pending a levels' do
    course = create(:course, :with_a_level_requirements, accept_pending_a_level: true, a_level_requirements: true)
    component = described_class.new(course: course.decorate)
    rendered_component = render_inline(component)

    expect(rendered_component.text).to include(I18n.t('course.consider_pending_a_level.row.true'))
  end

  it 'renders the pending a level summary content for non-acceptance when course does not accept pending a levels' do
    course = create(:course, :with_a_level_requirements, accept_pending_a_level: false, a_level_requirements: true)
    component = described_class.new(course: course.decorate)
    rendered_component = render_inline(component)

    expect(rendered_component.text).to include(I18n.t('course.consider_pending_a_level.row.false'))
  end

  it 'renders the a level equivalency summary content for acceptance when course accepts a level equivalencies' do
    course = create(:course, :with_a_level_requirements, accept_a_level_equivalency: true, a_level_requirements: true)
    component = described_class.new(course: course.decorate)
    rendered_component = render_inline(component)

    expect(rendered_component.text).to include(I18n.t('course.a_level_equivalencies.row.true'))
  end

  it 'renders the a level equivalency summary content for non-acceptance when course does not accept a level equivalencies' do
    course = create(:course, :with_a_level_requirements, accept_a_level_equivalency: false, a_level_requirements: true)
    component = described_class.new(course: course.decorate)
    rendered_component = render_inline(component)

    expect(rendered_component.text).to include(I18n.t('course.a_level_equivalencies.row.false'))
  end

  it 'renders the additional a level equivalencies content when present' do
    course = create(:course, :with_a_level_requirements, accept_a_level_equivalency: true, additional_a_level_equivalencies: 'Some additional information', a_level_requirements: true)
    component = described_class.new(course: course.decorate)
    rendered_component = render_inline(component)

    expect(rendered_component.text).to include('Some additional information')
  end

  it 'does not render the additional a level equivalencies when no equivalencies' do
    course = create(:course, :with_a_level_requirements, accept_a_level_equivalency: false, additional_a_level_equivalencies: 'Some additional information', a_level_requirements: true)
    component = described_class.new(course: course.decorate)
    rendered_component = render_inline(component)

    expect(rendered_component.text).not_to include('Some additional information')
  end

  it 'does not render the pending A level if the question is not answered' do
    a_level_subject_requirement = { 'subject' => 'other_subject', 'other_subject' => 'Math', 'minimum_grade_required' => 'A' }
    course = create(:course, :with_a_level_requirements, accept_pending_a_level: nil, a_level_requirements: true, a_level_subject_requirements: [a_level_subject_requirement])
    component = described_class.new(course: course.decorate)
    rendered_component = render_inline(component)

    expect(rendered_component.text).not_to include('Candidates with pending A levels will')
  end

  it 'does not render the equivalency A level if the question is not answered' do
    a_level_subject_requirement = { 'subject' => 'other_subject', 'other_subject' => 'Math', 'minimum_grade_required' => 'A' }
    course = create(:course, :with_a_level_requirements, accept_a_level_equivalency: nil, a_level_requirements: true, a_level_subject_requirements: [a_level_subject_requirement])
    component = described_class.new(course: course.decorate)
    rendered_component = render_inline(component)

    expect(rendered_component.text).not_to include('Equivalency tests will ')
  end

  it 'returns false for has_errors?' do
    course = create(:course)
    component = described_class.new(course: course.decorate)

    expect(component.has_errors?).to be(false)
  end

  describe 'when course has errors on A levels' do
    let(:rendered_component) { render_inline(component) }
    let(:component) do
      described_class.new(course: course.decorate, errors: format_publish_error_messages(course))
    end
    let(:course) do
      create(
        :course,
        :with_teacher_degree_apprenticeship,
        :resulting_in_undergraduate_degree_with_qts,
        :with_gcse_equivalency,
        :draft_enrichment,
        :with_a_level_requirements,
        attributes
      )
    end
    let(:attributes) { {} }

    before do
      course.valid?(:publish)
    end

    context 'when accept_a_level_equivalency is nil' do
      let(:attributes) { {  accept_a_level_equivalency: nil } }

      it 'renders the error message for accept_a_level_equivalency' do
        expect(rendered_component).to have_text(I18n.t("course.#{component.wizard_step(:accept_a_level_equivalency)}.heading"))
        expect(rendered_component).to have_link(
          component.errors[:accept_a_level_equivalency].first,
          href: publish_provider_recruitment_cycle_course_a_levels_a_level_equivalencies_path(
            course.provider.provider_code,
            course.provider.recruitment_cycle_year,
            course.course_code,
            display_errors: true
          )
        )
      end
    end

    context 'when a_level_requirements is nil' do
      let(:attributes) { { a_level_requirements: nil } }

      it 'renders the error message for a_level_requirements' do
        expect(rendered_component).to have_text(I18n.t("course.#{component.wizard_step(:a_level_requirements)}.heading"))
        expect(rendered_component).to have_link(
          component.errors[:a_level_requirements].first,
          href: publish_provider_recruitment_cycle_course_a_levels_are_any_a_levels_required_for_this_course_path(
            course.provider.provider_code,
            course.provider.recruitment_cycle_year,
            course.course_code,
            display_errors: true
          )
        )
      end
    end

    context 'when a_level_subject_requirements is blank' do
      let(:attributes) { {  a_level_requirements: true, a_level_subject_requirements: [] } }

      it 'renders the error message for a_level_subject_requirements' do
        expect(rendered_component).to have_text(I18n.t("course.#{component.wizard_step(:a_level_subject_requirements)}.heading"))
        expect(rendered_component).to have_link(
          component.errors[:a_level_subject_requirements].first,
          href: publish_provider_recruitment_cycle_course_a_levels_what_a_level_is_required_path(
            course.provider.provider_code,
            course.provider.recruitment_cycle_year,
            course.course_code,
            display_errors: true
          )
        )
      end
    end

    context 'when accept_pending_a_level is nil' do
      let(:attributes) { {  accept_pending_a_level: nil } }

      it 'renders the error message for accept_pending_a_level' do
        expect(rendered_component).to have_text(I18n.t("course.#{component.wizard_step(:accept_pending_a_level)}.heading"))
        expect(rendered_component).to have_link(
          component.errors[:accept_pending_a_level].first,
          href: publish_provider_recruitment_cycle_course_a_levels_consider_pending_a_level_path(
            course.provider.provider_code,
            course.provider.recruitment_cycle_year,
            course.course_code,
            display_errors: true
          )
        )
      end
    end
  end

  def format_publish_error_messages(course)
    course.errors.messages.transform_values do |error_messages|
      error_messages.map { |message| message.gsub(/^\^/, '') }
    end
  end
end
