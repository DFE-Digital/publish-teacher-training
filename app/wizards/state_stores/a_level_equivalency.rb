module StateStores
  class ALevelEquivalency
    include DfE::Wizard::StateStore

    delegate :accept_a_level_equivalency?, :additional_a_level_equivalencies, to: :current_step
    delegate :course, to: :wizard

    def save
      if accept_a_level_equivalency?
        course.update!(
          accept_a_level_equivalency: true,
          additional_a_level_equivalencies: additional_a_level_equivalencies.presence,
        )
      else
        course.update!(
          accept_a_level_equivalency: false,
          additional_a_level_equivalencies: nil,
        )
      end
    end
  end
end
