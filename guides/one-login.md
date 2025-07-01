# One Login

We use One Login to authenticate Candidates when they sign in to Find.

One Login is a Government wide authentication provider for users of Government services.

[General documentation](https://www.sign-in.service.gov.uk/documentation)
[Technical documentation](https://docs.sign-in.service.gov.uk/)

### Technical


#### OmniAuth

OmniAuth is a ruby libarary for managing OAuth clients.
Our system already uses an OmniAuth provider for DfESignIn on the Publish side.


#### How does OmniAuth work?

Re

OpenIdConnect

1. Sign in
2. Sign out
3. Backdoor logout
4. Session detection

## In what environments is One Login 

1. Production
2. QA
3. Review apps - needs configuring for each review app


## Setup new integration

1. Create an integration environment here
2. Create a key pair
    1. ```
       openssl genpkey -algorithm RSA -out private_key.pem -pkeyopt rsa_keygen_bits:2048
       openssl rsa -pubout -in private_key.pem -out public_key.pem
       ```
3. Put the public key in the admin tool
4. Set the private key in the application with `export ONE_LOGIN_PRIVATE_KEY="$(cat private_key.pem)"`
5. Add redirect url to `http://find.localhost:3001/auth/one-login/callback` in the admin tool

## One Login "admin tool"

We do not have a access to the One Login production configuration. We need to contact One Login if we want to change any production configuration.

One Login Admin console
https://admin.sign-in.service.gov.uk/sign-in/enter-email-address


