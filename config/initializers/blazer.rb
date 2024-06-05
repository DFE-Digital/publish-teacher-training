# frozen_string_literal: true

module Blazer
  class Record < ApplicationRecord
    self.abstract_class = true

    self.pluralize_table_names = true
  end
end
