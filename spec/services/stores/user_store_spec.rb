# frozen_string_literal: true

require "rails_helper"

require_relative "shared_examples/store"

module Stores
  describe UserStore do
    include_examples "store", :user, %i[user provider provider_contact accredited_provider provider_partnership]
  end
end
