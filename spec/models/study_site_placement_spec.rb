# frozen_string_literal: true

require 'rails_helper'

describe StudySitePlacement do
  it { is_expected.to belong_to(:course) }
  it { is_expected.to belong_to(:site) }
end
