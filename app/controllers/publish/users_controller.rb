module Publish
  class UsersController < PublishController
    def index
      authorize(provider)

      @users = provider.users
    end
  end
end
