# frozen_string_literal: true

module Persona
  class View < GovukComponent::Base
    attr_accessor :email_address, :first_name, :last_name

    def initialize(email_address:, first_name:, last_name:)
      super({})
      @email_address = email_address
      @first_name = first_name
      @last_name = last_name
    end
  end
end
