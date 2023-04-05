# frozen_string_literal: true

require 'rails_helper'

module Publish
  module Schools
    describe SelectForm, type: :model do
      subject { described_class.new }

      it { is_expected.to validate_presence_of(:school_id) }
    end
  end
end
