# frozen_string_literal: true

require 'rails_helper'

shared_examples 'select form' do
  it { is_expected.to validate_presence_of(:school_id) }
end
