# One Login

We use One Login to authenticate Candidates in Find.

One Login is a Government wide authentication provider for users of Government services.

- [General documentation](https://www.sign-in.service.gov.uk/documentation)
- [Technical documentation](https://docs.sign-in.service.gov.uk/)
- [One Login Admin Tool](https://admin.sign-in.service.gov.uk/sign-in/enter-email-address) 

### Technical Details

One Login implements the OAuth Open ID Connect


| Term                     | Explanation                                              |
| ---------------          | ---------------                                          |
| OAuth 2.0                | Protocol for Authorization                               |
| OpenID Connect           | Protocol for Authentication                              |
| OmniAuth                 | Ruby gem for OAuth                                       |
| omniauth-govuk-one-login | OmniAuth plugin for OpenID Connect specific to One Login |

#### OmniAuth

OmniAuth is a ruby libarary for managing OAuth clients.
Our system already uses an OmniAuth provider for DfESignIn on the Publish side and now we added One Login for candidates.


# Authentications namespace

Authentications::CandidateOmniAuth decide which oauth provider to use based on the current environment.

### What features of One Login our app uses 

1. Sign in

    1. Every request is tested to see if it matches our auth endpoint (`auth/one-login`)
        If it does, then the request is processed through the OmniAuth / OneLogin middleware.
        The GovukOneLogin library handles all the requests that are made to One Login.
        `/authorize`
        `/token`
        `/userinfo`
        `/logout`

1. Sign Out
    1. Our code uses the `LogoutUtility` provided by GovukOneLogin to make a logout reqeust to One Login
2. Backdoor logout
    1. We provide a public endpoint to which One Login makes a signed request with the user uid BackdoorLogoutUtility provided by GovukOneLogin to make a logout reqeust to One Login
3. Passive Authentication
    1. TBC


#### How does OmniAuth work?

We register a `provider` with its configuration in an initializer. (Authentications::CandidateOmniAuth)

When you register a provider with OmniAuth, it is created in a middleware and inserted in the middleware stack.
The middlware recognises url paths based on the configuration the provider is initialized with.

```ruby
provider :govuk_one_login,
    name: :"one-login", # This sets the :provider variable in /auth/:provider
    path_prefix: "/auth" # This sets the /auth segment in /auth/:provider

```

None of these routes are printed in `bin/rails routes`.
Just assume `/auth/:provider` and the `/:path_prefix/:provider_name/callback` url exist based on the configuration.

When the provider returns an error, the `/auth/failure` endpoint is called and the error messages is set as a query param. `/auth/failure?erorr=abc&message=def`. Our app renders `errors/omniauth` for the candidate interface.


### Our Setup
In production we use the `:govuk_one_login` provider and in all other environments we use the `:find_developer` provider, although we can enable One Login in any environment.


## One Login "admin tool"

We do not have a access to the One Login production configuration. We need to contact One Login if we want to create or change any production configuration.

One Login Admin console
The link to the Admin tool is at the top of the page.
##### Setup One Login
If you want to enable One Login provider in QA, review app or locally, these are the steps you should take:

1. Create a [One Login admin tool integration](https://admin.sign-in.service.gov.uk/sign-in/enter-email-address) 
2. Create a [public-private key pair](https://docs.sign-in.service.gov.uk/before-integrating/set-up-your-public-and-private-keys/#create-a-key-pair)
    1. Double check the docs that this is still the recommended approach
    2. ```
       openssl genpkey -algorithm RSA -out private_key.pem -pkeyopt rsa_keygen_bits:2048
       openssl rsa -pubout -in private_key.pem -out public_key.pem
       ```
3. In the admin tool, fill in
    1. the Redirect URL `https://HOSTNAME/auth/one-login/callback`
    2. the Public Key pem
4. Set the values in the review environment
    1. `make review edit-app-secrets`
    2. Set the `ONE_LOGIN_PRIVATE_KEY`
    3. Set the `ONE_LOGIN_CLIENT_ID`


## In what environments is One Login 

1. Production
2. QA
3. Review apps - needs configuring for each review app
