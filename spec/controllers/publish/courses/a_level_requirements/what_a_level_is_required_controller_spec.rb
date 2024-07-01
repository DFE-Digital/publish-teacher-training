# frozen_string_literal: true

require 'rails_helper'

module Publish
  module Courses
    module ALevelRequirements
      describe WhatALevelIsRequiredController do
        let(:provider) { user.providers.first }
        let(:user) { create(:user, :with_provider) }
        let(:course) do
          create(
            :course,
            :with_teacher_degree_apprenticeship,
            provider:,
            a_level_subject_requirements:
          )
        end
        let(:a_level_subject_requirements) do
          [{ uuid: 'a-uuid', subject: 'any_subject' }]
        end

        before do
          allow(controller).to receive(:authenticate).and_return(true)
          controller.instance_variable_set(:@current_user, user)
        end

        it_behaves_like 'an A level requirements controller'

        describe 'GET #new' do
          context 'when uuid is provided and found' do
            before do
              get :new, params: { provider_code: provider.provider_code, recruitment_cycle_year: provider.recruitment_cycle_year, course_code: course.course_code, uuid: 'a-uuid' }
            end

            it 'assign the existing subject requirement to current step' do
              current_step = assigns(:wizard).current_step
              expect(current_step.uuid).to eq('a-uuid')
              expect(current_step.subject).to eq('any_subject')
            end
          end

          context 'when uuid is provided but not found' do
            it 'raises ActiveRecord::RecordNotFound' do
              expect do
                get :new, params: { provider_code: provider.provider_code, recruitment_cycle_year: provider.recruitment_cycle_year, course_code: course.course_code, uuid: 'someuuid' }
              end.to raise_error(ActiveRecord::RecordNotFound)
            end
          end

          context 'when uuid is not provided' do
            it 'renders the :new template' do
              get :new, params: { provider_code: provider.provider_code, recruitment_cycle_year: provider.recruitment_cycle_year, course_code: course.course_code }
              expect(response).to render_template(:new)
            end
          end

          context 'when uuid is not provided and maximum A level subject requirements' do
            let(:a_level_subject_requirements) do
              4.times.map { |number| { uuid: "a-uuid-#{number}", subject: 'any_subject' } }
            end

            it 'redirects to A level list page' do
              get :new, params: { provider_code: provider.provider_code, recruitment_cycle_year: provider.recruitment_cycle_year, course_code: course.course_code }
              expect(response).to redirect_to(
                publish_provider_recruitment_cycle_course_a_levels_add_a_level_to_a_list_path(
                  provider.provider_code,
                  provider.recruitment_cycle_year,
                  course.course_code
                )
              )
            end
          end

          context 'when uuid is provided and maximum A level subject requirements' do
            let(:a_level_subject_requirements) do
              4.times.map { |number| { uuid: "a-uuid-#{number}", subject: 'any_subject' } }
            end

            it 'renders the page so user can edit the A level subject requirement' do
              get :new, params: { provider_code: provider.provider_code, recruitment_cycle_year: provider.recruitment_cycle_year, course_code: course.course_code, uuid: 'a-uuid-1' }
              expect(response).to render_template(:new)
            end
          end
        end

        describe 'POST #create' do
          context 'when uuid is not provided and maximum A level subject requirements' do
            let(:a_level_subject_requirements) do
              4.times.map { |number| { uuid: "a-uuid-#{number}", subject: 'any_subject' } }
            end

            before do
              post :create, params: {
                provider_code: provider.provider_code,
                recruitment_cycle_year: provider.recruitment_cycle_year,
                course_code: course.course_code,
                what_a_level_is_required: {
                  subject: 'any_science_subject'
                }
              }
            end

            it 'redirects to A level list page' do
              expect(response).to redirect_to(
                publish_provider_recruitment_cycle_course_a_levels_add_a_level_to_a_list_path(
                  provider.provider_code,
                  provider.recruitment_cycle_year,
                  course.course_code
                )
              )
            end

            it 'does not create more A level subject requirements' do
              expect(course.reload.a_level_subject_requirements.size).to be 4
            end
          end

          context 'when uuid is provided and maximum A level subject requirements' do
            let(:a_level_subject_requirements) do
              4.times.map { |number| { uuid: "a-uuid-#{number}", subject: 'any_subject' } }
            end

            before do
              post :create, params: {
                provider_code: provider.provider_code,
                recruitment_cycle_year: provider.recruitment_cycle_year,
                course_code: course.course_code,
                what_a_level_is_required: {
                  uuid: 'a-uuid-1',
                  subject: 'any_science_subject'
                }
              }
            end

            it 'redirects to A level list page' do
              expect(response).to redirect_to(
                publish_provider_recruitment_cycle_course_a_levels_add_a_level_to_a_list_path(
                  provider.provider_code,
                  provider.recruitment_cycle_year,
                  course.course_code
                )
              )
            end

            it 'does not create more A level subject requirements' do
              expect(course.reload.a_level_subject_requirements.size).to be 4
            end

            it 'updates A level subject requirements' do
              expect(course.reload.find_a_level_subject_requirement!('a-uuid-1')[:subject]).to eq('any_science_subject')
            end
          end
        end
      end
    end
  end
end
