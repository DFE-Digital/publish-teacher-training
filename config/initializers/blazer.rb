# frozen_string_literal: true

require 'blazer'

module Blazer
  class Record < ActiveRecord::Base
    self.abstract_class = true

    self.pluralize_table_names = true
  end
end
