# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '.changed_at_since' do
  context '30 days ago' do
    let!(:over_30_course) { create(:course, changed_at: 30.days.ago) }
    let!(:under_30_course) { create(:course, changed_at: 29.days.ago) }

    it 'includes course changed less than 30 days ago' do
      expect(Course.changed_at_since(30.days.ago)).to eq([under_30_course])
    end
  end
end
