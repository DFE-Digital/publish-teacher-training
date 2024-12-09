# frozen_string_literal: true

class ProviderPartnership < ApplicationRecord
  belongs_to :training_provider, class_name: 'Provider'
  belongs_to :accredited_provider, class_name: 'Provider'
end
