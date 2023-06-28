# frozen_string_literal: true

require 'rails_helper'

describe Course do
  describe '#update_valid' do
    let(:current_cycle) { find_or_create :recruitment_cycle }
    let(:next_cycle)    { find_or_create(:recruitment_cycle, :next) }
    let(:current_year)  { current_cycle.year.to_i }
    let(:next_year)     { next_cycle.year.to_i }

    context 'applications_open_from' do
      subject { course }

      let(:course) do
        create(:course,
               applications_open_from: current_cycle.application_start_date)
      end

      context 'for the current recruitment cycle' do
        context 'with a valid date' do
          its(:update_valid?) { is_expected.to be true }
        end

        context 'with an invalid date' do
          let(:course) do
            create(:course,
                   applications_open_from: DateTime.new(current_year, 10, 1))
          end

          its(:update_valid?) { is_expected.to be false }
        end
      end

      context 'for the next recruitment cycle' do
        let(:provider) { build(:provider, recruitment_cycle: next_cycle) }

        context 'with a valid date' do
          let(:course) do
            create(:course,
                   provider:,
                   applications_open_from: next_cycle.application_start_date,
                   study_sites: [build(:site, :study_site)])
          end

          its(:update_valid?) { is_expected.to be true }
        end

        context 'with an invalid date' do
          let(:course) do
            create(:course,
                   provider:,
                   applications_open_from: DateTime.new(current_year - 1, 10, 1))
          end

          its(:update_valid?) { is_expected.to be false }
        end
      end
    end

    context 'start_date' do
      subject { course }

      let(:course) { create(:course, start_date: DateTime.new(current_year, 9, 1)) }

      context 'for the current recruitment cycle' do
        context 'with a valid start date' do
          its(:update_valid?) { is_expected.to be true }
        end

        context 'with an invalid start date' do
          let(:course) { create(:course, start_date: DateTime.new(next_year, 9, 1)) }

          its(:update_valid?) { is_expected.to be false }
        end
      end

      context 'for the next recruitment cycle' do
        let(:provider) { build(:provider, recruitment_cycle: next_cycle) }
        let(:next_cycle) { create(:recruitment_cycle, :next) }

        context 'with a valid start date' do
          let(:course) do
            create(:course,
                   provider:,
                   study_sites: [build(:site, :study_site)],
                   start_date: DateTime.new(next_year, 9, 1))
          end

          its(:update_valid?) { is_expected.to be true }
        end

        context 'with an invalid start date' do
          let(:course) do
            create(:course,
                   provider:,
                   start_date: DateTime.new(next_year - 1, 9, 1))
          end

          its(:update_valid?) { is_expected.to be false }
        end
      end
    end
  end
end
