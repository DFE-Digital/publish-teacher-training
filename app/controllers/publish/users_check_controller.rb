module Publish
  class UsersCheckController < PublishController

    def show
      authorize(provider)

      @users = provider.users
    end
  end
end
