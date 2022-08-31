# frozen_string_literal: true

module FindInterface::Courses::ContentsComponent
  class ViewPreview < ViewComponent::Preview
    def default
      render FindInterface::Courses::ContentsComponent::View.new(mock_course)
    end

  private

    def mock_course
      FakeCourse.new(provider: Provider.new(provider_code: "DFE", website: "wwww.awesomeprovider@aol.com", train_with_disability: "foo"),
        about_course: "foo",
        how_school_placements_work: "bar",
        placements_heading: "School placements",
        about_accrediting_body: "foo",
        salaried: true,
        interview_process: "bar",
        has_vacancies: true)
    end

    class FakeCourse
      include ActiveModel::Model
      attr_accessor(:provider, :about_course, :how_school_placements_work, :placements_heading, :about_accrediting_body, :salaried, :interview_process, :has_vacancies)

      def has_bursary?
        has_bursary
      end

      def has_vacancies?
        has_vacancies
      end

      def salaried?
        salaried
      end
    end
  end
end
