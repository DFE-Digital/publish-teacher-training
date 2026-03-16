# frozen_string_literal: true

module Publish
  class AuthenticationService
    attr_accessor :encoded_token, :user

    def initialize(logger:)
      @logger = logger
    end

    class << self
      DFE_SIGNIN = "dfe_signin"
      PERSONA = "persona"
      MAGIC_LINK = "magic_link"

      def mode
        case Settings.authentication.mode
        when MAGIC_LINK
          MAGIC_LINK
        when PERSONA
          PERSONA
        else
          DFE_SIGNIN
        end
      end

      def dfe_signin?
        mode == DFE_SIGNIN
      end

      def magic_link?
        mode == MAGIC_LINK
      end

      def persona?
        mode == PERSONA
      end
    end
  end
end
