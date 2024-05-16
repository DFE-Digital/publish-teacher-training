# frozen_string_literal: true

require 'rails_helper'

module Publish
  describe CourseStudyModeForm, type: :model do
    let(:course) { create(:course) }

    subject { described_class.new(course, params:) }

    context 'when params are blank' do
      let(:params) { {} }

      describe '#save!' do
        it 'does not save any changes' do
          expect(subject.save!).to be false
        end
      end
    end

    context 'when params are study mode is part_time' do
      let(:params) { { study_mode: ['part_time'] } }

      describe '#save!' do
        it 'does calls the course.ensure_site_statuses_match_study_mode' do
          allow(course).to receive(:changed?).and_return true
          expect(course).to receive(:ensure_site_statuses_match_study_mode)
          subject.save!
        end

        it 'saves the study mode as part time' do
          subject.save!

          expect(course.study_mode).to eq 'part_time'
        end
      end
    end

    context 'when params are study mode is both part time and full time' do
      let(:params) { { study_mode: %w[full_time part_time] } }

      it 'does calls the course.ensure_site_statuses_match_study_mode' do
        allow(course).to receive(:changed?).and_return true
        expect(course).to receive(:ensure_site_statuses_match_study_mode)
        subject.save!
      end

      it 'saves the study mode as full_time_or_part_time' do
        subject.save!

        expect(course.study_mode).to eq 'full_time_or_part_time'
      end
    end

    context 'when params are study mode is full time' do
      let(:params) { { study_mode: ['full_time'] } }

      it 'does calls the course.ensure_site_statuses_match_study_mode' do
        allow(course).to receive(:changed?).and_return true
        expect(course).to receive(:ensure_site_statuses_match_study_mode)
        subject.save!
      end

      it 'saves the study mode as full time' do
        subject.save!

        expect(course.study_mode).to eq 'full_time'
      end
    end
  end
end
