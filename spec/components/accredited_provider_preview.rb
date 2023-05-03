# frozen_string_literal: true

class AccreditedProviderPreview < ViewComponent::Preview
  def default
    render(AccreditedProvider.new(
             provider_name: 'Provider name',
             remove_path: 'remove_path',
             about_accredited_provider: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nunc imperdiet nunc ex, eget faucibus eros mattis dictum. Pellentesque odio augue, commodo in consectetur sit amet, feugiat vel leo. Nulla ullamcorper, purus sit amet lobortis sollicitudin, justo leo congue sem, nec cursus mauris justo et est. In convallis mi id libero pulvinar aliquet. In eu mi vel nunc venenatis efficitur. Etiam eget rutrum lacus, nec finibus justo. Integer sed augue sit amet libero ornare elementum. Aenean accumsan sapien vitae lacus condimentum, non finibus ex malesuada. Proin in nisi lacus.',
             change_about_accredited_provider_path: 'change_about_accredited_provider_path'
           ))
  end
end
