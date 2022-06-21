module Publish
  class NotificationsController < PublishController
    skip_before_action :check_interrupt_redirects

    def index
      authorize(current_user, :index?)

      @notifications_view = NotificationsView.new(request:, current_user:)
      @notification_form = NotificationForm.new(current_user)
    end

    def update
      authorize(current_user, :update?)

      @notification_form = NotificationForm.new(current_user, params: notification_params)

      if @notification_form.save!
        flash[:success] = "Email notification preferences for #{current_user.email} have been saved."

        redirect_to redirect_to_path
      else
        @notifications_view = NotificationsView.new(request:, current_user:)
        render(:index)
      end
    end

  private

    def redirect_to_path
      if permitted_params[:provider_code].present?
        publish_provider_path(permitted_params[:provider_code])
      else
        root_path
      end
    end

    def permitted_params
      params.require(:publish_notification_form).permit(*NotificationForm::FIELDS, :provider_code)
    end

    def notification_params
      permitted_params.except(:provider_code).transform_values do |value|
        ActiveModel::Type::Boolean.new.cast(value)
      end
    end
  end
end
