# frozen_string_literal: true

require 'rails_helper'

describe CourseSubject do
  describe 'associations' do
    it { is_expected.to belong_to(:course) }
  end

  describe 'auditing' do
    it { is_expected.to be_audited }
  end
end
