# frozen_string_literal: true

class BaseWizard
  class CheckAnswers
    include DfE::Wizard::Step

    def self.permitted_params
      []
    end
  end
end
