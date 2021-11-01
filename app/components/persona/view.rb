# frozen_string_literal: true

module Persona
  class View < GovukComponent::Base
    attr_accessor :email_address, :first_name, :last_name, :tags

    def initialize(
      email_address:,
      first_name:,
      last_name:,
      tags: [],
      classes: [],
      html_attributes: nil
    )
      super(classes: classes, html_attributes: html_attributes)
      @email_address = email_address
      @first_name = first_name
      @last_name = last_name
      @tags = tags
    end
  end
end
