# frozen_string_literal: true

require "rails_helper"

module Publish
  module Providers
    module Schools
      describe SearchForm, type: :model do
        subject { described_class.new }

        it { is_expected.to validate_presence_of(:query).on(:query) }

        it { is_expected.to validate_length_of(:query).on(:query).is_at_least(2) }
      end
    end
  end
end
