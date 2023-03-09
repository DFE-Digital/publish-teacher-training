# frozen_string_literal: true

require 'rails_helper'

require_relative 'shared_examples/store'

module Stores
  describe ProviderStore do
    include_examples 'store', :provider, %i[raw_csv_schools parsed_csv_schools]
  end
end
