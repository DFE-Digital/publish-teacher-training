module Find
  class CandidateAuthenticator
    attr_reader :oauth

    def initialize(oauth:)
      @oauth = oauth
    end

    # 1. Find existing Candidate via provider authentication
    # 2. Update Candidate email if it has changed
    # 3. Create a new candidate if one does not exist yet
    def call
      email_address = oauth.info.email
      authentication = ::Authentication.find_by(subject_key: oauth.uid)

      if authentication.present?
        candidate = authentication.authenticable
        unless candidate.email_address.casecmp?(email_address)
          candidate.update(email_address:)
        end
      else
        Candidate.transaction do
          candidate = Candidate.create(email_address:)

          provider = ::Authentication.provider_map(oauth.provider)
          candidate.authentications.build(provider:, subject_key: oauth.uid)
          candidate.save!
        end
      end
      candidate
    end
  end
end
