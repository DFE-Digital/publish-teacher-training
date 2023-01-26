# frozen_string_literal: true

module Find
  module Courses
    module ContactDetailsComponent
      class ViewPreview < ViewComponent::Preview
        def with_email
          course = Course.new(provider: Provider.new(provider_code: "DFE", email: "learn@learsomuch.com")).decorate
          render Find::Courses::ContactDetailsComponent::View.new(course)
        end

        def with_telephone
          course = Course.new(provider: Provider.new(provider_code: "DFE", telephone: "0207 123 1234")).decorate
          render Find::Courses::ContactDetailsComponent::View.new(course)
        end

        def with_website
          course = Course.new(provider: Provider.new(provider_code: "DFE", website: "www.gov.uk")).decorate
          render Find::Courses::ContactDetailsComponent::View.new(course)
        end

        def with_all
          course = Course.new(provider: Provider.new(
            email: "learn@learsomuch.com",
            telephone: "0207 123 1234",
            website: "www.gov.uk",
          )).decorate
          render Find::Courses::ContactDetailsComponent::View.new(course)
        end
      end
    end
  end
end
