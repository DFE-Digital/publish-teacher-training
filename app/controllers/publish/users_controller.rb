module Publish
  class UsersController < PublishController
    def index
      authorize(provider, :index?)
      @users = provider.users
    end
  end
end
