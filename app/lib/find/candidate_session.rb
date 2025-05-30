module Find
  class CandidateSession
    # Initial requrest there is no coookie
    # We initialize the cookie
    # Seconds request we authenticate the session
    # Third request we unauthenticate the session
    #
    # Questions:
    #   Do we want to store data in the cookie that out lasts the session
    #   Should that data be stored in other cookies
    def initialize(cookies)
      @cookies = cookies
    end

    def [](element)
      @cookies.signed[:candidate_session][element]
    end

    def get
      @cookies.signed[:candidate_session] ||= new_session
      @cookies.signed[:candidate_session]
    end

    def set(key, val)
      sess = get || {}
      sess = sess.deep_merge({ key => val })
      @cookies.signed[:candidate_session] = new_session(sess)
    end

    def reset
      @cookies.delete(:candidate_session)
    end

    def update(val); end

    def new_session(value = nil)
      { value:, httponly: true, same_site: :lax }
    end
  end
end
