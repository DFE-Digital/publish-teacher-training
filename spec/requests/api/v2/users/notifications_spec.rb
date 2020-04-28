require "rails_helper"

describe "/api/v2/users/:user_id/notifications" do
  context "user connected to two accredited bodies" do
    it "returns two user notifications" do
      given_an_accredited_body_exists
      given_another_accredited_body_exists
      given_a_non_accredited_body_exists
      given_i_am_an_authenticated_user_from_these_accredited_bodies
      given_i_am_an_authenticated_user_from_a_non_accredited_body

      when_valid_parameters_are_posted_opting_in_to_notifications

      then_two_new_opt_in_notifications_are_created
    end
  end

  context "with invalid parameters" do
    it "returns 422 with errors" do
      given_an_accredited_body_exists
      given_i_am_an_authenticated_user_from_the_accredited_body

      when_invalid_parameters_are_posted_to_the_notifications_endpoint

      then_notification_errors_are_returned
    end
  end

  context "opting out of course create and update notifications" do
    it "returns 201" do
      given_an_accredited_body_exists
      given_i_am_an_authenticated_user_from_the_accredited_body

      when_valid_parameters_are_posted_opting_out_of_notifications

      then_a_new_opt_out_notification_is_created
    end
  end

  context "user has already opted in to notifications" do
    it "returns only two user notifications" do
      given_an_accredited_body_exists
      given_another_accredited_body_exists
      given_i_am_an_authenticated_user_from_these_accredited_bodies
      given_i_have_opted_in_to_notifications_already

      when_valid_parameters_are_posted_opting_in_to_notifications

      then_two_existing_opt_in_notifications_are_created
    end
  end

  def given_an_accredited_body_exists
    @accredited_body_one = create(:provider, :accredited_body)
  end

  def given_another_accredited_body_exists
    @accredited_body_two = create(:provider, :accredited_body)
  end

  def given_a_non_accredited_body_exists
    @body = create(:provider)
  end

  def given_i_am_an_authenticated_user_from_the_accredited_body
    @user = create(:user)
    @user.organisations << @accredited_body_one.organisation
    payload = { email: @user.email }
    token = JWT.encode payload, Settings.authentication.secret, Settings.authentication.algorithm

    @credentials = ActionController::HttpAuthentication::Token.encode_credentials(token)
  end

  def given_i_am_an_authenticated_user_from_a_non_accredited_body
    @user.organisations << @body.organisations
    payload = { email: @user.email }
    token = JWT.encode payload, Settings.authentication.secret, Settings.authentication.algorithm

    @credentials = ActionController::HttpAuthentication::Token.encode_credentials(token)
  end

  def given_i_am_an_authenticated_user_from_these_accredited_bodies
    @user = create(:user)
    @user.organisations << @accredited_body_one.organisation
    @user.organisations << @accredited_body_two.organisation
    payload = { email: @user.email }
    token = JWT.encode payload, Settings.authentication.secret, Settings.authentication.algorithm

    @credentials = ActionController::HttpAuthentication::Token.encode_credentials(token)
  end

  def given_i_have_opted_in_to_notifications_already
    when_valid_parameters_are_posted_opting_in_to_notifications
  end

  def when_valid_parameters_are_posted_opting_in_to_notifications
    params = {
      "_jsonapi" => {
        "data" => {
          "type" => "user_notifications",
          "attributes" => {
            "course_create" => "true",
            "course_update" => "true",
          },
        },
      },
    }

    post "/api/v2/users/#{@user.id}/notifications?include=provider%2Cuser",
         params: params,
         headers: { "HTTP_AUTHORIZATION" => @credentials }
  end

  def when_invalid_parameters_are_posted_to_the_notifications_endpoint
    params = {
      "_jsonapi" => {
        "data" => {
          "type" => "user_notifications",
          "attributes" => {
            "course_create" => "",
            "course_update" => "",
          },
        },
      },
    }

    post "/api/v2/users/#{@user.id}/notifications",
         params: params,
         headers: { "HTTP_AUTHORIZATION" => @credentials }
  end

  def when_valid_parameters_are_posted_opting_out_of_notifications
    params = {
      "_jsonapi" => {
        "data" => {
          "type" => "user_notifications",
          "attributes" => {
            "course_create" => "false",
            "course_update" => "false",
          },
        },
      },
    }

    post "/api/v2/users/#{@user.id}/notifications",
         params: params,
         headers: { "HTTP_AUTHORIZATION" => @credentials }
  end

  def then_two_new_opt_in_notifications_are_created
    expect(response).to have_http_status(:created)
    parsed_response = JSON.parse(response.body)
    expect(@user.user_notifications.count).to eq(2)
    expect(parsed_response["data"].first["type"]).to eq("user_notifications")
    expect(parsed_response["data"].count).to eq(2)
    expect(parsed_response["data"].first["attributes"]["course_create"]).to eq(true)
    expect(parsed_response["data"].first["attributes"]["course_update"]).to eq(true)
  end

  def then_notification_errors_are_returned
    expect(response).to have_http_status(:unprocessable_entity)
    parsed_response = JSON.parse(response.body)
    expect(parsed_response["errors"]).to be_present
  end

  def then_two_existing_opt_in_notifications_are_created
    expect(response).to have_http_status(:created)
    parsed_response = JSON.parse(response.body)
    expect(@user.user_notifications.count).to eq(2)
    expect(parsed_response["data"].first["type"]).to eq("user_notifications")
    expect(parsed_response["data"].count).to eq(2)
    expect(parsed_response["data"].first["attributes"]["course_create"]).to eq(true)
    expect(parsed_response["data"].first["attributes"]["course_update"]).to eq(true)
  end

  def then_a_new_opt_out_notification_is_created
    expect(response).to have_http_status(:created)
    parsed_response = JSON.parse(response.body)
    expect(parsed_response["data"].first["type"]).to eq("user_notifications")
    expect(parsed_response["data"].first["attributes"]["course_create"]).to eq(false)
    expect(parsed_response["data"].first["attributes"]["course_update"]).to eq(false)
  end
end
