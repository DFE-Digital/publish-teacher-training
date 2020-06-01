require "rails_helper"
describe "user notification preferences service" do
  describe "GET /user_notification_preferences/:user_id" do
    context "when the user is not authenticated" do
      it "returns not authorized" do
        given_i_am_an_unauthenticated_user
        when_i_get_the_user_notification_preferences_endpoint_with_my_user_id
        then_i_receive_not_authorized
      end
    end

    context "when the user is authenticated" do
      it "returns the user notification preferences" do
        given_i_am_an_authenticated_user
        when_i_get_the_user_notification_preferences_endpoint_with_my_user_id
        then_i_receive_my_notification_preferences
      end
    end
  end

  describe "PUT /user_notification_preferences/:user_id" do
    context "when the user is not authenticated" do
      it "returns not authorized" do
        given_i_am_an_unauthenticated_user
        when_i_put_enabled_false_to_the_notification_preferences_endpoint
        then_i_receive_not_authorized
      end
    end

    context "when the user is authenticated" do
      it "returns the user notification preferences" do
        given_i_am_an_authenticated_user
        given_i_have_enabled_notifications
        when_i_put_enabled_false_to_the_notification_preferences_endpoint
        then_i_receive_the_disabled_notification_preferences
      end
    end
  end

  def given_i_am_an_unauthenticated_user
    @user = create(:user)
  end

  def given_i_have_enabled_notifications
    create(:user_notification, user: @user, course_publish: true, course_update: true)
  end

  def then_i_receive_not_authorized
    expect(response).to have_http_status :unauthorized
  end

  def given_i_am_an_authenticated_user
    @user = create(:user)
    payload = { email: @user.email }
    token = JWT.encode payload, Settings.authentication.secret, Settings.authentication.algorithm

    @credentials = ActionController::HttpAuthentication::Token.encode_credentials(token)
  end

  def when_i_get_the_user_notification_preferences_endpoint_with_my_user_id
    get "/api/v2/user_notification_preferences/#{@user.id}",
        headers: { "HTTP_AUTHORIZATION" => @credentials }
  end

  def then_i_receive_my_notification_preferences
    expect(JSON.parse(response.body).dig("data", "id")).to eq(@user.id.to_s)
  end

  def when_i_put_enabled_false_to_the_notification_preferences_endpoint
    params = {
      "_jsonapi" => {
        "data" => {
          "type" => "user_notification_preferences",
          "attributes" => {
            "enabled" => "false",
          },
        },
      },
    }
    put "/api/v2/user_notification_preferences/#{@user.id}",
        params: params,
        headers: { "HTTP_AUTHORIZATION" => @credentials }
  end

  def then_i_receive_the_disabled_notification_preferences
    expect(JSON.parse(response.body).dig("data", "attributes", "enabled")).to eq(false)
  end
end
