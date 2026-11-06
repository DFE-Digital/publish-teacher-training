# frozen_string_literal: true

class Support::AddProviderWizard
  module Steps
    class ContactDetails
      include DfE::Wizard::Step

      ADDRESS_FIELDS = %i[address1 address2 address3 town address4 postcode].freeze

      attribute :email, :string
      attribute :telephone, :string
      attribute :website, :string
      ADDRESS_FIELDS.each { |field| attribute field, :string }

      validates :email, presence: true, email_address: true
      validates :telephone, phone: true
      validates :website, presence: true, url: true
      validates :address1, :town, presence: true
      validates :postcode, presence: true, postcode: true

      def self.permitted_params
        [:email, :telephone, :website, *ADDRESS_FIELDS]
      end

      def full_address
        ADDRESS_FIELDS.map { |field| public_send(field) }
                      .compact_blank
                      .map { |line| ERB::Util.html_escape(line) }
                      .join("<br> ")
                      .html_safe
      end
    end
  end
end
