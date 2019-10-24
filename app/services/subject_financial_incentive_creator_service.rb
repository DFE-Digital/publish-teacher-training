class SubjectFinancialIncentiveCreatorService
  def initialize(subject: Subject, financial_incentive: FinancialIncentive)
    @subject = subject
    @financial_incentive = financial_incentive
  end

  def execute
    subject_and_financial_incentives = {
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
    }

    subject_and_financial_incentives.each do |subject_name, financial_incentive_attributes|
      @subject.where(subject_name: subject_name).each do |subject|
        @financial_incentive.find_or_create_by(subject: subject, **financial_incentive_attributes)
      end
    end
  end
end
