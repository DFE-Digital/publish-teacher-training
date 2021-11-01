# This is a copy of the Publish ApplicationController. It was copied across
# with all functionality commented out. Lines are gradually uncommented as
# they are needed for the Publish/TTAPI merge. Anything left commented after
# the merge is complete can be deleted.

class PublishInterfaceController < ApplicationController
  # protect_from_forgery with: :exception, except: :not_found
  # rescue_from JsonApiClient::Errors::NotAuthorized, with: :render_unauthorized
  # rescue_from JsonApiClient::Errors::AccessDenied, with: :handle_access_denied
  # rescue_from JsonApiClient::Errors::NotFound, with: :handle_not_found

  # include Pagy::Backend
  # include AdminOnlyMaintenanceMode
  # include EmitRequestEvents

  # before_action :http_basic_auth
  # before_action :authenticate
  # before_action :store_request_id
  # before_action :request_login
  # before_action :check_interrupt_redirects

  # def not_found
  #   respond_with_error(template: "errors/not_found", status: :not_found, error_text: "Resource not found")
  # end

  # def render_unauthorized
    # Backend responds with 401 if there is no matching record in the users table.
    # Show the "We don't know which organisation you're part of" page to give users a route
    # to getting access
    # render "providers/no_providers", status: :unauthorized
  # end

  # def handle_access_denied(exception)
  #   if user_has_not_accepted_terms(exception.env.body)
  #     redirect_to accept_terms_path
  #   else
  #     respond_with_error(template: "errors/forbidden", status: :forbidden, error_text: "Forbidden request")
  #   end
  # end

  # def handle_not_found
  #   render template: "errors/not_found", status: :not_found
  # end

  # helper_method :current_user

  # def current_user
  #   if is_authenticated?
  #     @current_user ||= session[:auth_user]
  #   end
  # end

  # def is_authenticated?
  #   session[:auth_user].present?
  # end

  # def user_is_admin?
  #   current_user["admin"]
  # end

  # def user_state
  #   current_user["state"]
  # end

  # def log_safe_current_user(reload: false)
  #   if @log_safe_current_user.nil? || reload
  #     email = current_user["info"]&.fetch("email", "")

  #     @log_safe_current_user = {
  #       email_md5: Digest::MD5.hexdigest(email),
  #       sign_in_user_id: current_user["uid"],
  #       user_id: current_user["user_id"],
  #     }
  #   end
  #   @log_safe_current_user
  # end

  def authenticate
    # if current_user.present?
    #   logger.info { "Authenticated user session found " + log_safe_current_user.to_s }

    #   assign_sentry_contexts
    #   assign_logstash_contexts
    #   add_token_to_connection
    #   set_has_multiple_providers

    #   if current_user["user_id"].blank?
    #     set_user_session
    #     Sentry.set_user(id: current_user["user_id"])
    #     logger.debug { "User session set. " + log_safe_current_user(reload: true).to_s }
    #   end
    # end
    super
    set_has_multiple_providers
  end

  # def request_login
  #   return if current_user.present?

  #   logger.info("Authenticated user session not found " + {
  #     redirect_back_to: request.path,
  #   }.to_s)
  #   session[:redirect_back_to] = request.path
  #   redirect_to sign_in_path
  # end

  # def current_user_info
  #   current_user["info"]
  # end

  # def current_user_dfe_signin_id
  #   current_user["uid"]
  # end

  def set_has_multiple_providers
    @has_multiple_providers = has_multiple_providers?
  end

  def has_multiple_providers?
    provider_count = session.to_hash.dig("auth_user", "provider_count")
    provider_count.nil? || provider_count > 1
  end

# private

  # def http_basic_auth
  #   if AuthenticationService.basic_auth?
  #     authenticate_or_request_with_http_basic do |name, password|
  #       name == Settings.authentication.basic_auth.username && Digest::SHA512.hexdigest(password) == Settings.authentication.basic_auth.password_digest
  #     end
  #   end
  # end

  # def check_interrupt_redirects(use_redirect_back_to: true)
  #   if !user_from_session.accepted_terms?
  #     redirect_to accept_terms_path
  #   elsif user_state_to_redirect_paths[user_from_session.aasm.current_state]
  #     redirect_to user_state_to_redirect_paths[user_from_session.aasm.current_state]
  #   elsif show_rollover_page?
  #     redirect_to rollover_path
  #   elsif show_rollover_recruitment_page?
  #     redirect_to rollover_recruitment_path
  #   elsif use_redirect_back_to
  #     redirect_to session[:redirect_back_to] if session[:redirect_back_to].present?
  #     session.delete(:redirect_back_to)
  #   end
  # end

  # def show_rollover_page?
  #   FeatureService.enabled?("rollover.can_edit_current_and_next_cycles") && !session[:auth_user]["accepted_rollover"]
  # end

  # def show_rollover_recruitment_page?
  #   FeatureService.enabled?("rollover.show_next_cycle_allocation_recruitment_page") && !session[:auth_user]["accepted_rollover_recruitment"]
  # end

  # def user_state_to_redirect_paths
  #   { new: transition_info_path }
  # end

  # def authorise_development_mode?(email, password)
  #   _, user = Settings.authorised_users.find do |_index, user|
  #     user.email == email && user.password == password
  #   end

  #   user
  # end

  # def setup_development_mode_session(email:, first_name:, last_name:)
  #   session[:auth_user] = HashWithIndifferentAccess.new(
  #     uid: SecureRandom.uuid,
  #     info: HashWithIndifferentAccess.new(
  #       email: email,
  #       first_name: first_name,
  #       last_name: last_name,
  #     ),
  #     credentials: HashWithIndifferentAccess.new(
  #       id_token: "id_token",
  #     ),
  #   )
  # end

  # def user_has_not_accepted_terms(response_body)
  #   return false unless response_body.is_a?(Hash)

  #   response_body.key?("meta") &&
  #     response_body["meta"]["error_type"] == "user_not_accepted_terms_and_conditions"
  # end

  # def respond_with_error(template:, status:, error_text:)
  #   respond_to do |format|
  #     format.html { render template, status: status }
  #     format.json { render json: { error: error_text }, status: status }
  #     format.all { render status: status, body: nil }
  #   end
  # end

  # def set_user_session
  #   logger.debug do
  #     "Creating new session for user " + {
  #       email_md5: log_safe_current_user["email_md5"],
  #       signin_id: current_user_dfe_signin_id,
  #     }.to_s
  #   end

  #   # TODO: we should return a session object here with a 'user' attached to id.
  #   user = Session.create(
  #     first_name: current_user_info[:first_name],
  #     last_name: current_user_info[:last_name],
  #   )
  #   set_session_info_for_user(user)

  #   user
  # end

  # def set_session_info_for_user(user)
  #   session[:auth_user]["user_id"] = user.id
  #   session[:auth_user]["state"] = user.state
  #   session[:auth_user]["associated_with_accredited_body"] = user.associated_with_accredited_body
  #   session[:auth_user]["notifications_configured"] = user.notifications_configured
  #   session[:auth_user]["accepted_terms?"] = user.accept_terms_date_utc.present?
  #   session[:auth_user]["admin"] = user.admin
  #   session[:auth_user]["attributes"] = user.attributes

  #   add_provider_count_cookie
  #   add_interrupt_pages
  # end

  # def user_from_session
  #   User.new(
  #     current_user["attributes"],
  #   )
  # end

  # def add_provider_count_cookie
  #   session[:auth_user][:provider_count] =
  #     Provider.where(recruitment_cycle_year: Settings.current_cycle).all.size
  # rescue StandardError => e
  #   logger.error "Error setting the provider_count cookie: #{e.class.name}, #{e.message}"
  # end

  # def add_interrupt_pages
  #   return unless FeatureService.enabled?("rollover.can_edit_current_and_next_cycles") || FeatureService.enabled?("rollover.show_next_cycle_allocation_recruitment_page")

  #   InterruptPageAcknowledgement.where(user_id: current_user["user_id"], recruitment_cycle_year: Settings.current_cycle).all.each do |acknowledgement|
  #     key = "accepted_#{acknowledgement.page}"
  #     session[:auth_user][key] = true
  #   end
  # end

  # def add_token_to_connection
  #   payload = {
  #     email: current_user_info["email"].to_s,
  #     first_name: current_user_info["first_name"].to_s,
  #     last_name: current_user_info["last_name"].to_s,
  #     sign_in_user_id: current_user_dfe_signin_id,
  #   }

  #   # Attempting to debug blanking of name information
  #   if payload[:first_name].blank?
  #     logger.warn "first_name missing for sign in user id: #{payload[:sign_in_user_id]}"
  #   end

  #   if payload[:last_name].blank?
  #     logger.warn "last_name missing for sign in user id: #{payload[:sign_in_user_id]}"
  #   end

  #   if payload[:email].blank?
  #     logger.warn "email missing for sign in user id: #{payload[:sign_in_user_id]}"
  #   end
  #   # end of debugging

  #   token = JWT::EncodeService.call(payload: payload)

  #   RequestStore.store[:manage_courses_backend_token] = token
  # end

  # def assign_sentry_contexts
  #   Sentry.set_user(id: current_user["user_id"])
  #   Sentry.set_tags(sign_in_user_id: current_user.fetch("uid"))
  #   Sentry.set_extras(request_id: request.uuid)
  # end

  # def assign_logstash_contexts
  #   Thread.current[:logstash] ||= {}
  #   Thread.current[:logstash][:user_id] = current_user["user_id"]
  #   Thread.current[:logstash][:sign_in_user_id] = current_user["uid"]
  # end

  # def append_info_to_payload(payload)
  #   super

  #   if current_user.present?
  #     payload[:user] = {
  #       id: current_user["user_id"],
  #       sign_in_user_id: current_user.fetch("uid"),
  #     }
  #     payload[:request_id] = request.uuid
  #   end
  # end

  # def store_request_id
  #   RequestStore.store[:request_id] = request.uuid
  # end
end
