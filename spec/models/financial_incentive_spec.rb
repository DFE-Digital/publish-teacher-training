# frozen_string_literal: true

require 'rails_helper'

describe FinancialIncentive do
  describe 'associations' do
    it { is_expected.to belong_to(:subject) }
  end
end
