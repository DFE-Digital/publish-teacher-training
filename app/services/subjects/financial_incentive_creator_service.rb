module Subjects
  class FinancialIncentiveCreatorService
    def initialize(year:, subject: Subject, financial_incentive: FinancialIncentive)
      @subject = subject
      @financial_incentive = financial_incentive
      @year = year
    end

    def subject_and_financial_incentives
      subject_and_financial_incentives = {
        2023 => {
          %w[Mathematics Physics Chemistry Computing] => {
            bursary_amount: "27000",
            scholarship: "29000",
          },
          ["French", "German", "Italian", "Japanese", "Mandarin", "Modern languages (other)", "Russian", "Spanish"] => {
            bursary_amount: "25000",
            scholarship: "27000",
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
      subject_and_financial_incentives.each do |subject_name, financial_incentive_attributes|
        @subject.where(subject_name:).each do |subject|
          @financial_incentive.find_or_create_by(subject:, **financial_incentive_attributes)
        end
      end
    end
  end
end
