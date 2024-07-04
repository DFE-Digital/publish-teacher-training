# frozen_string_literal: true

require 'rails_helper'

module Find
  describe GotoPreviewHelper do
    let(:param_form_key) { :param_form_key }

    describe '#goto_preview_value' do
      subject do
        goto_preview_value(param_form_key:, params:)
      end

      context 'params is empty' do
        let(:params) { {} }

        it 'returns falsey' do
          expect(subject).to be_nil
        end
      end

      context 'params has goto_preview set to "true"' do
        let(:params) { { goto_preview: 'true' } }

        it 'returns truthy' do
          expect(subject).to eq('true')
        end
      end

      context 'params has param_form_key with goto_preview set to "true"' do
        let(:params) { { param_form_key: { goto_preview: 'true' } } }

        it 'returns truthy' do
          expect(subject).to eq('true')
        end
      end
    end

    describe '#goto_preview?' do
      subject do
        goto_preview?(param_form_key:, params:)
      end

      context 'params is empty' do
        let(:params) { {} }

        it 'returns falsey' do
          expect(subject).to be_falsey
        end
      end

      context 'params has goto_preview set to "true"' do
        let(:params) { { goto_preview: 'true' } }

        it 'returns truthy' do
          expect(subject).to be_truthy
        end
      end

      context 'params has param_form_key with goto_preview set to "true"' do
        let(:params) { { param_form_key: { goto_preview: 'true' } } }

        it 'returns truthy' do
          expect(subject).to be_truthy
        end
      end
    end

    describe '#goto_provider_value' do
      subject do
        goto_provider_value(param_form_key:, params:)
      end

      context 'params is empty' do
        let(:params) { {} }

        it 'returns falsey' do
          expect(subject).to be_nil
        end
      end

      context 'params has goto_provider set to "true"' do
        let(:params) { { goto_provider: 'true' } }

        it 'returns truthy' do
          expect(subject).to eq('true')
        end
      end

      context 'params has param_form_key with goto_provider set to "true"' do
        let(:params) { { param_form_key: { goto_provider: 'true' } } }

        it 'returns truthy' do
          expect(subject).to eq('true')
        end
      end
    end

    describe '#goto_provider?' do
      subject do
        goto_provider?(param_form_key:, params:)
      end

      context 'params is empty' do
        let(:params) { {} }

        it 'returns falsey' do
          expect(subject).to be_falsey
        end
      end

      context 'params has goto_provider set to "true"' do
        let(:params) { { goto_provider: 'true' } }

        it 'returns truthy' do
          expect(subject).to be_truthy
        end
      end

      context 'params has param_form_key with goto_provider set to "true"' do
        let(:params) { { param_form_key: { goto_provider: 'true' } } }

        it 'returns the value "true"' do
          expect(subject).to be_truthy
        end
      end

      context 'params has param_form_key with goto_provider set to "false"' do
        let(:params) { { param_form_key: { goto_provider: 'false' } } }

        it 'returns the value "false"' do
          expect(subject).to be_falsey
        end
      end
    end

    describe '#back_link_path' do
      let(:course) { build(:course) }

      subject do
        back_link_path(param_form_key:,
                       params:,
                       provider_code: course.provider.provider_code,
                       recruitment_cycle_year: course.recruitment_cycle_year,
                       course_code: course.course_code)
      end

      context 'params is empty' do
        let(:params) { {} }

        it 'returns publish course url' do
          expect(subject).to eq(
            "/publish/organisations/#{course.provider.provider_code}/#{course.recruitment_cycle_year}/courses/#{course.course_code}"
          )
        end
      end

      context 'params has goto_preview set to "true"' do
        let(:params) { { goto_preview: 'true' } }

        it 'returns preview course url' do
          expect(subject).to eq(
            "/publish/organisations/#{course.provider.provider_code}/#{course.recruitment_cycle_year}/courses/#{course.course_code}/preview"
          )
        end
      end

      context 'params has param_form_key with goto_preview set to "true"' do
        let(:params) { { param_form_key: { goto_preview: 'true' } } }

        it 'returns preview course url' do
          expect(subject).to eq(
            "/publish/organisations/#{course.provider.provider_code}/#{course.recruitment_cycle_year}/courses/#{course.course_code}/preview"
          )
        end
      end
    end
  end
end
