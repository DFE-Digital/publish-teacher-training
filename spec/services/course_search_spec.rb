class CourseSearch
  def initialize(filter:, recruitment_cycle_year:)
    @filter = filter
    @recruitment_cycle_year = recruitment_cycle_year
  end

  class << self
    def call(**args)
      new(args).call
    end
  end

  def call
    scope = Course.all
    scope = scope.only_with_salary if funding_filter_salary?
    scope
  end

  private_class_method :new

private

  attr_reader :filter, :recruitment_cycle_year

  def funding_filter_salary?
    filter[:funding] == "salary"
  end
end

RSpec.describe CourseSearch do
  describe ".call" do
    subject { described_class.call(filter: filter, recruitment_cycle_year: current_recruitment_cycle_year) }

    let(:current_recruitment_cycle_year) { Settings.current_recruitment_cycle_year }

    context "filter[funding]" do
      let(:salary_course) { create(:course, :with_salary) }
      let(:not_salary_course) { create(:course) }

      before do
        salary_course
        not_salary_course
      end

      context "salary" do
        let(:filter) { { funding: "salary" } }

        # expect(Course).to receive(:all).and_return(all_scope)
        # expect(all_scope).to receive(:only_with_salary)

        it { is_expected.to contain_exactly(salary_course) }
      end

      context "all" do
        let(:filter) { { funding: "all" } }

        it { is_expected.to contain_exactly(salary_course, not_salary_course) }
      end
    end
  end
end
