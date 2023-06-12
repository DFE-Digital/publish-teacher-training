# frozen_string_literal: true

require 'rails_helper'

module Publish
  module StudySites
    describe SelectForm, type: :model do
      subject { described_class.new }

      include_examples 'select form'
    end
  end
end
