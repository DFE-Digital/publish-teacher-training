# frozen_string_literal: true

module Subjects
  class FinancialIncentiveCreatorService
    DEFAULT_ATTRIBUTES = {
      bursary_amount: nil,
      scholarship: nil,
      early_career_payments: nil,
      non_uk_bursary_eligible: false,
      non_uk_scholarship_eligible: false,
    }.freeze

    def initialize(year:, displayed: false, subject: Subject, financial_incentive: FinancialIncentive)
      @subject = subject
      @financial_incentive = financial_incentive
      @year = year.to_i
      @displayed = displayed
    end

    def subject_and_financial_incentives
      subject_and_financial_incentives = {
        2026 => {
          %w[Mathematics] => {
            bursary_amount: "29000",
          },
          %w[Chemistry Computing] => {
            bursary_amount: "29000",
            scholarship: "31000",
          },
          %w[Physics] => {
            bursary_amount: "29000",
            scholarship: "31000",
            non_uk_bursary_eligible: false,
            non_uk_scholarship_eligible: false,
          },
          %w[French German Spanish] => {
            bursary_amount: "20000",
            scholarship: "22000",
            non_uk_bursary_eligible: false,
            non_uk_scholarship_eligible: false,
          },
          [
            "Ancient Greek",
            "Ancient Hebrew",
            "Latin",
            "Italian",
            "Japanese",
            "Mandarin",
            "Modern languages (other)",
            "Modern Languages",
            "Russian",
          ] => {
            bursary_amount: "20000",
            non_uk_bursary_eligible: false,
          },
          ["Design and technology"] => {
            bursary_amount: "20000",
          },
          %w[Biology Geography] => {
            bursary_amount: "5000",
          },
        },
        2025 => {
          %w[Mathematics Physics Chemistry Computing] => {
            bursary_amount: "29000",
            scholarship: "31000",
          },
          %w[French German Spanish] => {
            bursary_amount: "26000",
            scholarship: "28000",
          },
          [
            "Italian",
            "Japanese",
            "Latin",
            "Mandarin",
            "Modern languages (other)",
            "Russian",
            "Italian",
            "Ancient Greek",
            "Ancient Hebrew",
          ] => {
            bursary_amount: "26000",
          },
          ["Geography", "Biology", "Design and technology"] => {
            bursary_amount: "26000",
          },
          ["Art and design", "Music", "Religious education"] => {
            bursary_amount: "10000",
          },
          %w[English] => {
            bursary_amount: "5000",
          },
        },
        2024 => {
          %w[Mathematics Physics Chemistry Computing] => {
            bursary_amount: "28000",
            scholarship: "30000",
          },
          %w[
            French
            German
            Spanish
          ] => {
            bursary_amount: "25000",
            scholarship: "27000",
          },
          [
            "Italian",
            "Japanese",
            "Mandarin",
            "Modern languages (other)",
            "Russian",
          ] => {
            bursary_amount: "25000",
          },
          ["Biology", "Design and technology", "Geography"] => {
            bursary_amount: "25000",
          },
          ["English", "Art and design", "Music", "Religious education"] => {
            bursary_amount: "10000",
          },
        },
        2023 => {
          %w[Mathematics Physics Chemistry Computing] => {
            bursary_amount: "27000",
            scholarship: "29000",
          },
          %w[
            French
            German
            Spanish
          ] => {
            bursary_amount: "25000",
            scholarship: "27000",
          },
          [
            "Italian",
            "Japanese",
            "Mandarin",
            "Modern languages (other)",
            "Russian",
          ] => {
            bursary_amount: "25000",
          },
          [
            "Latin",
            "Ancient Greek",
            "Ancient Hebrew",
          ] => {
            bursary_amount: "25000",
          },
          %w[Geography] => {
            bursary_amount: "25000",
          },
          ["Biology", "Design and technology"] => {
            bursary_amount: "20000",
          },
          %w[English] => {
            bursary_amount: "15000",
          },
        },
        2022 => {
          ["Latin", "Ancient Greek", "Ancient Hebrew"] => {
            bursary_amount: "15000",
          },
        },
        2021 => {
          %w[Biology] => {
            bursary_amount: "7000",
          },
          %w[Chemistry Computing Mathematics Physics] => {
            scholarship: "26000",
            bursary_amount: "24000",
          },
          %w[Classics] => {
            bursary_amount: "10000",
          },
          ["French", "German", "Italian", "Japanese", "Mandarin", "Modern languages (other)", "Russian", "Spanish"] => { bursary_amount: "10000" },
        },
        2020 => {
          ["Primary with mathematics"] => {
            bursary_amount: "6000",
          },
          %w[Biology Classics] => {
            bursary_amount: "26000",
          },
          %w[French German Spanish] => {
            bursary_amount: "26000",
            scholarship: "28000",
            early_career_payments: "2000",
          },
          %w[Computing] => {
            bursary_amount: "26000",
            scholarship: "28000",
          },
          %w[Geography] => {
            bursary_amount: "15000",
            scholarship: "17000",
          },
          ["Italian", "Japanese", "Mandarin", "Russian", "Modern languages (other)"] => {
            bursary_amount: "26000",
            early_career_payments: "2000",
          },
          ["Art and design", "Business studies", "History", "Music", "Religious education"] => {
            bursary_amount: "9000",
          },
          %w[English] => {
            bursary_amount: "12000",
          },
          ["Design and technology"] => {
            bursary_amount: "15000",
          },
          %w[Chemistry Mathematics Physics] => {
            bursary_amount: "26000",
            scholarship: "28000",
            early_career_payments: "2000",
          },
        },
      }
      subject_and_financial_incentives[@year] || {}
    end

    def execute
      @financial_incentive.transaction do
        reset_target_year_financial_incentives

        subject_and_financial_incentives.each do |subject_names, financial_incentive_attributes|
          @subject.where(subject_name: subject_names).find_each do |subject|
            financial_incentive_record = @financial_incentive.find_or_initialize_by(subject:, year: @year)
            financial_incentive_record.assign_attributes(DEFAULT_ATTRIBUTES.merge(financial_incentive_attributes))

            if @displayed
              financial_incentive_record.display!
            else
              financial_incentive_record.save!
            end
          end
        end
      end
    end

  private

    def reset_target_year_financial_incentives
      @financial_incentive.for_year(@year).find_each do |financial_incentive|
        financial_incentive.update!(DEFAULT_ATTRIBUTES)
      end
    end
  end
end
