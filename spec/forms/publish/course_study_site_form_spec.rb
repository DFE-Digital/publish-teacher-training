# frozen_string_literal: true

require 'rails_helper'

module Publish
  describe CourseStudySiteForm, type: :model do
    let(:course) { create(:course) }

    subject { described_class.new(course) }

    describe 'validations' do
      before { subject.valid? }

      it 'validates :study_site_ids' do
        expect(subject.errors[:study_site_ids]).to include(I18n.t('activemodel.errors.models.publish/course_study_site_form.attributes.study_site_ids.blank'))
      end
    end
  end
end
