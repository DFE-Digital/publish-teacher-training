# frozen_string_literal: true

require 'rails_helper'

describe Courses::EditOptions::StartDateConcern do
  let(:example_model) { create(:course) }

  let(:year) { example_model.provider.recruitment_cycle.year.to_i }

  context 'non presisted course' do
    context 'start_date_options' do
      it 'returns the correct options for the recruitment_cycle' do
        expect(example_model.start_date_options).to eq(
          ["October #{year - 1}",
           "November #{year - 1}",
           "December #{year - 1}",
           "January #{year}",
           "February #{year}",
           "March #{year}",
           "April #{year}",
           "May #{year}",
           "June #{year}",
           "July #{year}",
           "August #{year}",
           "September #{year}",
           "October #{year}",
           "November #{year}",
           "December #{year}",
           "January #{year + 1}",
           "February #{year + 1}",
           "March #{year + 1}",
           "April #{year + 1}",
           "May #{year + 1}",
           "June #{year + 1}",
           "July #{year + 1}"]
        )
      end
    end
  end

  context 'presisted course' do
    let(:example_model) { build(:course) }
    let(:month) { [*1..12].sample }
    let(:expected_starting_options) do
      [
        nil,
        "January #{year}",
        "February #{year}",
        "March #{year}",
        "April #{year}",
        "May #{year}",
        "June #{year}",
        "July #{year}",
        "August #{year}",
        "September #{year}",
        "October #{year}",
        "November #{year}",
        "December #{year}"
      ][month..12].compact
    end

    let(:expected_available_options) do
      [

        *expected_starting_options,
        "January #{year + 1}",
        "February #{year + 1}",
        "March #{year + 1}",
        "April #{year + 1}",
        "May #{year + 1}",
        "June #{year + 1}",
        "July #{year + 1}"
      ]
    end

    around do |example|
      Timecop.freeze(Time.zone.local(Settings.current_recruitment_cycle_year, month, 1)) do
        example.run
      end
    end

    it 'returns the available options for the recruitment_cycle' do
      expect(example_model.start_date_options).to eq(expected_available_options)
    end
  end
end
