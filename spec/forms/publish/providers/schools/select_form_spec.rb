# frozen_string_literal: true

require 'rails_helper'

module Publish
  module Providers
    module Schools
      describe SelectForm, type: :model do
        subject { described_class.new }

        include_examples 'select form'
      end
    end
  end
end
