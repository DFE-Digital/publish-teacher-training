module Find
  class CandidateAuthenticator
    attr_reader :oauth

    def initialize(oauth:)
      @oauth = oauth
    end

    # 1. Find existing Candidate via provider authentication
    # 2. Update Candidate email if it has changed
    # 3. Create a new candidate if one does not exist yet
    # @return Candidate
    def call
      if authentication.present?
        sign_in!
      else
        sign_up!
      end
    end

  private

    # @return Candidate
    def sign_up!
      candidate = nil
      Candidate.transaction do
        candidate = Candidate.create(email_address:)

        provider = ::Authentication.provider_map(oauth.provider)
        candidate.authentications.build(provider:, subject_key: oauth.uid)
        candidate.save!
      end
      candidate
    end

    # @return Candidate
    def sign_in!
      authentication.authenticable.tap do |candidate|
        unless candidate.email_address.casecmp?(email_address)
          candidate.update(email_address:)
        end
      end
    end

    # @return Authentication
    def authentication
      @authentication ||= ::Authentication.find_by(subject_key: oauth.uid)
    end

    def email_address
      oauth.info.email
    end
  end
end
