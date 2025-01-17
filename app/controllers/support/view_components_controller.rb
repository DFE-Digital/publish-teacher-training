# frozen_string_literal: true

module Support
  class ViewComponentsController < ApplicationController
    include ViewComponent::PreviewActions

    helper_method :shared_component_previews, :find_component_previews, :publish_component_previews

    def index
      @previews = case params[:namespace]
                  when 'find'
                    find_component_previews
                  when 'publish'
                    publish_component_previews
                  else
                    shared_component_previews
                  end

      @previews.sort_by!(&:name)

      render :index
    end

    def previews
      find_preview

      if params[:path] == @preview.preview_name
        @page_title = "Component Previews for #{@preview.preview_name}"
        render :previews, **determine_layout
      else
        prepend_application_view_paths
        prepend_preview_examples_view_path
        @example_name = File.basename(params[:path])
        @render_args = @preview.render_args(@example_name, params: params.permit!)
        layout = determine_layout(@render_args[:layout], prepend_views: false)[:layout]
        locals = @render_args[:locals]
        opts = {}
        opts[:layout] = layout if layout.present? || layout == false
        opts[:locals] = locals if locals.present?
        render :preview, opts
      end
    end

    private

    def shared_component_previews
      @shared_component_previews ||= ViewComponent::Preview.all.reject { |preview| preview.name.deconstantize.split('::')[0].in?(%w[Find Publish]) }
    end

    def find_component_previews
      @find_component_previews ||= ViewComponent::Preview.all.filter { |preview| preview.name.deconstantize.split('::')[0] == 'Find' }
    end

    def publish_component_previews
      @publish_component_previews ||= ViewComponent::Preview.all.filter { |preview| preview.name.deconstantize.split('::')[0] == 'Publish' }
    end
  end
end
