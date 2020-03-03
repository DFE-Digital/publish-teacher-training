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
  end

  around :each do |example|
    default_per_page = Kaminari.config.default_per_page

    Kaminari.configure do |config|
      config.default_per_page = 1
    end

    example.run

    Kaminari.configure do |config|
      config.default_per_page = default_per_page
    end
  end

  describe "pagination" do
    before do
      provider = create(:provider)
      2.times.map { create(:course, provider: provider) }
    end

    it "is enabled by default" do
      get :index
      expect(JSON.parse(response.body)["data"].size).to eql(1)
    end

    it "can not be disabled only with per_page param" do
      get :index, params: { page: { per_page: 100_000 } }
      expect(JSON.parse(response.body)["data"].size).to eql(1)
    end

    context "when allowed_to_disable_pagination? returns true" do
      it "can be disabled with per_page param and implemented method" do
        controller.instance_eval do
          def allowed_to_disable_pagination?
            true
          end
        end

        get :index, params: { page: { per_page: 100_000 } }
        expect(JSON.parse(response.body)["data"].size).to eql(2)
      end
    end
  end
end
