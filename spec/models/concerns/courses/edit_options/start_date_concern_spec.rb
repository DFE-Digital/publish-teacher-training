# frozen_string_literal: true

require 'rails_helper'

describe Courses::EditOptions::StartDateConcern do
  let(:example_model) do
    klass = Class.new do
      include Courses::EditOptions::StartDateConcern
      attr_accessor :provider
    end

    klass.new
  end

  let(:provider) { build(:provider) }

  before do
    example_model.provider = provider
  end

  context 'start_date_options' do
    let(:year) { provider.recruitment_cycle.year.to_i }

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
