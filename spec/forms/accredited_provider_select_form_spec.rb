# frozen_string_literal: true

require 'rails_helper'

describe AccreditedProviderSelectForm, type: :model do
  subject { described_class.new }

  it { is_expected.to validate_presence_of(:provider_id) }
end
