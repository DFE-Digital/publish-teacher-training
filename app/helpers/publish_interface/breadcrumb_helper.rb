module PublishInterface
  module BreadcrumbHelper
    def render_breadcrumbs(type)
      breadcrumbs = send("#{type}_breadcrumb")

      # Don't link last item in breadcrumb
      breadcrumbs[breadcrumbs.keys.last] = nil

      if breadcrumbs
        render GovukComponent::BreadcrumbsComponent.new(
          breadcrumbs: breadcrumbs,
          classes: "govuk-!-display-none-print",
        )
      end
    end

    def organisations_breadcrumb
      @has_multiple_providers ? { "Organisations" => publish_interface_providers_path } : {}
    end

    def provider_breadcrumb
      path = publish_interface_provider_path(@provider.provider_code)
      organisations_breadcrumb.merge({ @provider.provider_name => path })
    end

    def recruitment_cycle_breadcrumb
      if @provider.rolled_over?
        path = provider_recruitment_cycle_path(@provider.provider_code, @recruitment_cycle.year)
        provider_breadcrumb.merge({ @recruitment_cycle.title => path })
      else
        provider_breadcrumb
      end
    end

    # def courses_breadcrumb
    #   path = provider_recruitment_cycle_courses_path(@provider.provider_code)
    #   recruitment_cycle_breadcrumb.merge({ "Courses" => path })
    # end

    # def course_breadcrumb
    #   path = provider_recruitment_cycle_course_path(@provider.provider_code, course.recruitment_cycle_year, course.course_code)
    #   courses_breadcrumb.merge({ course.name_and_code => path })
    # end

    # def sites_breadcrumb
    #   path = provider_recruitment_cycle_sites_path(@provider.provider_code, @recruitment_cycle.year)
    #   recruitment_cycle_breadcrumb.merge({ "Locations" => path })
    # end

    def organisation_details_breadcrumb
      path = details_publish_interface_provider_recruitment_cycle_path(@provider.provider_code, @provider.recruitment_cycle.year)
      recruitment_cycle_breadcrumb.merge({ "About your organisation" => path })
    end

    # def users_breadcrumb
    #   path = details_provider_recruitment_cycle_path(@provider.provider_code, @recruitment_cycle.year)
    #   recruitment_cycle_breadcrumb.merge({ "Users" => path })
    # end

    # def edit_site_breadcrumb
    #   path = edit_provider_recruitment_cycle_site_path(@provider.provider_code, @site.recruitment_cycle_year, @site.id)
    #   sites_breadcrumb.merge({ @site_name_before_update => path })
    # end

    # def new_site_breadcrumb
    #   path = new_provider_recruitment_cycle_site_path(@provider.provider_code)
    #   sites_breadcrumb.merge({ "Add a location" => path })
    # end

    # def ucas_contacts_breadcrumb
    #   path = provider_ucas_contacts_path(@provider.provider_code)
    #   provider_breadcrumb.merge({ "UCAS contacts" => path })
    # end

    # def training_providers_breadcrumb
    #   path = training_providers_provider_recruitment_cycle_path(@provider.provider_code, @provider.recruitment_cycle_year)
    #   provider_breadcrumb.merge({ "Courses as an accredited body" => path })
    # end

    # def training_provider_courses_breadcrumb
    #   path = training_provider_courses_provider_recruitment_cycle_path(@provider.provider_code, @provider.recruitment_cycle_year, @training_provider.provider_code)
    #   training_providers_breadcrumb.merge({ "#{@training_provider.provider_name}’s courses" => path })
    # end

    # def allocations_breadcrumb
    #   path = provider_recruitment_cycle_allocations_path(@provider.provider_code, @provider.recruitment_cycle_year)
    #   provider_breadcrumb.merge({ "Request PE courses for #{next_allocation_cycle_period_text}" => path })
    # end

    # def allocations_closed_breadcrumb
    #   path = provider_recruitment_cycle_allocations_path(@provider.provider_code, @provider.recruitment_cycle_year)
    #   provider_breadcrumb.merge({ "PE courses for #{next_allocation_cycle_period_text}" => path })
    # end
  end
end
