# frozen_string_literal: true

module BreadcrumbHelper
  def render_breadcrumbs(type)
    breadcrumbs = send("#{type}_breadcrumb")

    # Don't link last item in breadcrumb
    breadcrumbs[breadcrumbs.keys.last] = nil
  end

  # rubocop:disable Rails/HelperInstanceVariable
  def organisations_breadcrumb
    current_user.has_multiple_providers? ? { "Organisations" => root_path } : {}
  end

  def provider_breadcrumb
    path = publish_provider_path(code: @provider.provider_code)
    organisations_breadcrumb.merge({ @provider.provider_name => path })
  end

  def recruitment_cycle_breadcrumb
    if @provider.rolled_over?
      path = publish_provider_recruitment_cycle_path(@provider.provider_code, @recruitment_cycle.year)
      provider_breadcrumb.merge({ @recruitment_cycle.title => path })
    else
      provider_breadcrumb
    end
  end

  def courses_breadcrumb
    path = publish_provider_recruitment_cycle_courses_path(@provider.provider_code)
    recruitment_cycle_breadcrumb.merge({ "Courses" => path })
  end

  def course_breadcrumb
    path = publish_provider_recruitment_cycle_course_path(@provider.provider_code, course.recruitment_cycle_year, course.course_code)
    courses_breadcrumb.merge({ course.name_and_code => path })
  end

  def sites_breadcrumb
    path = publish_provider_recruitment_cycle_schools_path(@provider.provider_code, @recruitment_cycle.year)
    recruitment_cycle_breadcrumb.merge({ "Schools" => path })
  end

  def study_sites_breadcrumb
    path = publish_provider_recruitment_cycle_study_sites_path(@provider.provider_code, @recruitment_cycle.year)
    recruitment_cycle_breadcrumb.merge({ "Study sites" => path })
  end

  def organisation_details_breadcrumb
    path = details_publish_provider_recruitment_cycle_path(@provider.provider_code, @recruitment_cycle.year)
    recruitment_cycle_breadcrumb.merge({ "About your organisation" => path })
  end

  def users_breadcrumb
    path = details_publish_provider_recruitment_cycle_path(@provider.provider_code, @recruitment_cycle.year)
    recruitment_cycle_breadcrumb.merge({ "Users" => path })
  end

  def edit_site_breadcrumb
    path = edit_publish_provider_recruitment_cycle_school_path(@provider.provider_code, @recruitment_cycle.year, @site.id)
    sites_breadcrumb.merge({ @site.location_name.dup => path })
  end

  def new_site_breadcrumb
    path = new_publish_provider_recruitment_cycle_school_path(@provider.provider_code)
    sites_breadcrumb.merge({ "Add a location" => path })
  end

  def training_providers_breadcrumb
    path = publish_provider_recruitment_cycle_training_partners_path(@provider.provider_code, @provider.recruitment_cycle_year)
    provider_breadcrumb.merge({ "Courses as an Accredited provider" => path })
  end

  def training_provider_courses_breadcrumb
    path = publish_provider_recruitment_cycle_training_partner_courses_path(@provider.provider_code, @provider.recruitment_cycle_year, @training_partner.provider_code)
    training_providers_breadcrumb.merge({ "#{@training_partner.provider_name}’s courses" => path })
  end
  # rubocop:enable Rails/HelperInstanceVariable
end
