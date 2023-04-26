# frozen_string_literal: true

require 'rails_helper'

describe AccreditedProviderSearchForm, type: :model do
  subject { described_class.new }

  it { is_expected.to validate_presence_of(:query) }

  it { is_expected.to validate_length_of(:query).is_at_least(2) }
end
