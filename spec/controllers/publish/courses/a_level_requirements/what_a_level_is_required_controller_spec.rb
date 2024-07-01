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
            a_level_subject_requirements: [{ uuid: 'a-uuid', subject: 'any_subject' }]
          )
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
        end
      end
    end
  end
end
