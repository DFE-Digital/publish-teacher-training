# frozen_string_literal: true

require_relative "base"

module PageObjects
  module Sections
    class RelatedSidebar < PageObjects::Sections::Base
      element :copy_form, '[data-qa="course__copy-content-form"]'
      element :use_content, '[data-qa="course__use_content"]'
    end
  end
end