# frozen_string_literal: true

module Support
  module ClearStashable
    extend ActiveSupport::Concern

    def reset_accredited_provider_form
      accredited_provider_form.clear_stash
    end
  end
end
