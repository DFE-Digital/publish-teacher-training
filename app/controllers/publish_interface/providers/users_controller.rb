module Providers
  class UsersController < ApplicationController
    def index
      cycle_year = params.fetch(:year, Settings.current_cycle)
      @recruitment_cycle = RecruitmentCycle.find(cycle_year).first

      @provider = Provider.includes(:users)
                    .where(recruitment_cycle_year: @recruitment_cycle.year)
                    .find(params[:code])
                    .first

      @users = @provider.users
    end
  end
end
