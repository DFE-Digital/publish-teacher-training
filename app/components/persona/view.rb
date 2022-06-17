# frozen_string_literal: true

module Persona
  class View < ApplicationComponent
    attr_accessor :email_address, :first_name, :last_name

    def initialize(
      email_address:,
      first_name:,
      last_name:,
      classes: [],
      html_attributes: {}
    )
      super(classes: classes, html_attributes: html_attributes)
      @email_address = email_address
      @first_name = first_name
      @last_name = last_name
    end
  end
end
