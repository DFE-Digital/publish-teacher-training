# frozen_string_literal: true

require 'rails_helper'

require_relative 'shared_examples/store'

module Stores
  describe CourseStore do
    include_examples 'store', :course, %i[funding_types_and_visas]
  end
end
