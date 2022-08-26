# frozen_string_literal: true

module FindInterface::Courses::FinancialSupport::FeesAndFinancialSupportComponent
  class ViewPreview < ViewComponent::Preview
    def salaried
      course = Course.new(funding_type: "salary").decorate
      render FindInterface::Courses::FinancialSupport::FeesAndFinancialSupportComponent::View.new(course)
    end

    def salaried_with_fees
      render FindInterface::Courses::FinancialSupport::FeesAndFinancialSupportComponent::View.new(salaried_with_fees_course)
    end

    def excluded_from_bursary
      render FindInterface::Courses::FinancialSupport::FeesAndFinancialSupportComponent::View.new(excluded_from_bursary_course)
    end

    def bursary_only
      render FindInterface::Courses::FinancialSupport::FeesAndFinancialSupportComponent::View.new(bursary_only_course)
    end

    def scholarship_and_bursary
      render FindInterface::Courses::FinancialSupport::FeesAndFinancialSupportComponent::View.new(scholarship_and_bursary_course)
    end

    def financial_support_available
      render FindInterface::Courses::FinancialSupport::FeesAndFinancialSupportComponent::View.new(financial_support_course)
    end

  private

    def salaried_with_fees_course
      FakeCourse.new(has_fees: true,
        salaried: true,
        excluded_from_bursary: false,
        bursary_only: false,
        has_scholarship_and_bursary: false,
        financial_support: false,
        fee_uk_eu: 99999,
        fee_international: 9000000000,
        cycle_range: "2022 to 2023",
        fee_details: "The course fees for UK students in 2022 to 2023 are £9,250.")
    end

    def excluded_from_bursary_course
      FakeCourse.new(has_fees: true,
        salaried: false,
        excluded_from_bursary: true,
        bursary_only: false,
        has_scholarship_and_bursary: false,
        financial_support: false,
        fee_uk_eu: 99999,
        fee_international: 9000000000,
        cycle_range: "2022 to 2023",
        fee_details: "The course fees for UK students in 2022 to 2023 are £9,250.")
    end

    def bursary_only_course
      FakeCourse.new(has_fees: false,
        salaried: false,
        excluded_from_bursary: false,
        bursary_only: true,
        has_scholarship_and_bursary: false,
        financial_support: false,
        fee_uk_eu: 99999,
        fee_international: 9000000000,
        cycle_range: "2022 to 2023",
        fee_details: "The course fees for UK students in 2022 to 2023 are £9,250.",
        bursary_amount: 99999999)
    end

    def scholarship_and_bursary_course
      FakeCourse.new(has_fees: false,
        salaried: false,
        excluded_from_bursary: false,
        bursary_only: false,
        has_scholarship_and_bursary: true,
        financial_support: false,
        fee_uk_eu: 99999,
        fee_international: 9000000000,
        cycle_range: "2022 to 2023",
        fee_details: "The course fees for UK students in 2022 to 2023 are £9,250.",
        bursary_amount: 99999999,
        scholarship_amount: 1,
        has_early_career_payments: true,
        subject_name: "foobar")
    end

    def financial_support_course
      FakeCourse.new(has_fees: false,
        salaried: false,
        excluded_from_bursary: false,
        bursary_only: false,
        has_scholarship_and_bursary: false,
        financial_support: "Much support available",
        fee_uk_eu: 99999,
        fee_international: 9000000000,
        cycle_range: "2022 to 2023",
        fee_details: "The course fees for UK students in 2022 to 2023 are £9,250.",
        bursary_amount: 99999999,
        scholarship_amount: 1,
        has_early_career_payments: false,
        subject_name: "foobar")
    end

    class FakeCourse
      include ActiveModel::Model
      attr_accessor(:has_fees, :salaried, :excluded_from_bursary, :bursary_only, :has_scholarship_and_bursary, :financial_support, :fee_uk_eu, :fee_international, :cycle_range, :fee_details, :bursary_amount, :scholarship_amount, :has_early_career_payments, :subject_name)

      def enrichment_attribute(params)
        send(params)
      end

      def has_fees?
        has_fees
      end

      def excluded_from_bursary?
        excluded_from_bursary
      end

      def salaried?
        salaried
      end

      def bursary_only?
        bursary_only
      end

      def has_scholarship_and_bursary?
        has_scholarship_and_bursary
      end

      def has_early_career_payments?
        has_early_career_payments
      end
    end
  end
end
