class SignInController < ApplicationController
  skip_before_action :authenticate
end
