# frozen_string_literal: true

module Publish
  class RepeatRequestForm
    include ActiveModel::Model

    attr_accessor :request_type

    validates :request_type, presence: { message: "Select one option" }
  end
end
