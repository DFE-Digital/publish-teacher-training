require "rails_helper"

RSpec.describe API::V3::ApplicationController do
  controller do
    def index
      render jsonapi: paginate(Course.all),
        class: CourseSerializersService.new.execute
    end

  private

    def page_url(_)
      "/"
    end

    def max_per_page
      1
    end
  end

  describe "pagination" do
    before do
      provider = create(:provider)
      2.times.map { create(:course, provider:) }
    end

    it "is enabled by default" do
      get :index
      expect(JSON.parse(response.body)["data"].size).to be(1)
    end

    it "can not be disabled only with per_page param" do
      get :index, params: { page: { per_page: 100_000 } }
      expect(JSON.parse(response.body)["data"].size).to be(1)
    end

    context "when custom max_per_page" do
      it "is respected" do
        controller.instance_eval do
          def max_per_page
            100_000
          end
        end

        get :index, params: { page: { per_page: 100_000 } }
        expect(JSON.parse(response.body)["data"].size).to be(2)
      end
    end
  end
end
