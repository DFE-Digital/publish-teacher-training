# Candidate Authentication

This document describes the authentication process for candidates in **Find**. The authentication system supports two providers:

1. **One Login** - Used in production and other government-related environments.
2. **FindDeveloper** - A custom OmniAuth strategy used for developer and testing environments (e.g., QA, local development, and review apps).

## Overview of Authentication Providers

### One Login
**One Login** is the government-wide authentication provider used for candidates in the production environment. It handles both authentication and authorization using the **OAuth 2.0** and **OpenID Connect** protocols.

- [General Documentation](https://www.sign-in.service.gov.uk/documentation)
- [Technical Documentation](https://docs.sign-in.service.gov.uk/)
- [One Login Admin Tool](https://admin.sign-in.service.gov.uk/sign-in/enter-email-address)

### FindDeveloper

**FindDeveloper** is a custom OmniAuth strategy designed specifically for use in development and non-production environments. It mimics the authentication flow of **One Login** but is used to simplify local development and testing.

- [OmniAuth Documentation](https://github.com/omniauth/omniauth)

## Technical Overview

Both **One Login** and **FindDeveloper** use the **OAuth 2.0** and **OpenID Connect** protocols to handle authorization and authentication. The primary difference is that **FindDeveloper** is a mock authentication strategy used to simulate the behavior of **One Login** in development and testing environments.

### Terminology

| Term                     | Explanation                                              |
|--------------------------|----------------------------------------------------------|
| **OAuth 2.0**             | A protocol for authorization (allowing users to grant access to their resources). |
| **OpenID Connect**        | A protocol built on top of OAuth 2.0, used for authentication (proving identity). |
| **OmniAuth**              | A Ruby library for managing OAuth clients.                |
| **omniauth-govuk-one-login** | An OmniAuth plugin specifically for integrating with One Login via OpenID Connect. |
| **FindDeveloper**         | A custom OmniAuth strategy for development environments. |


---

Find service users One Login only to authenticate the user, not to prove their identity. As such, the claims and scopes we define are minimal.

| Field            | Value         |
| ---              | ---           |
| Scope            | OpenID, Email |
| Vectors of Trust | P0            |
---

## Authentication Flow

The authentication flow is largely the same for both providers, but with different endpoints and configurations depending on the environment.

1. **Sign In**:
   - Every incoming request is checked to determine if it matches the authentication endpoint (`/auth/one-login` for One Login or `/auth/find_developer` for FindDeveloper).
   - If the request matches, it's processed through the OmniAuth middleware, which handles requests to the respective provider's endpoints:
     - **One Login**: `/authorize`, `/token`, `/userinfo`, `/logout`
     - **FindDeveloper**: Mimics the same flow, but using mock data for local development.

2. **Sign Out**:
   - The application uses the `LogoutUtility` from **GovukOneLogin** to send a logout request to One Login.
   - For **FindDeveloper**, the logout flow is simulated.

1. **Backchannel Logout**:
   - We provide a public endpoint that One Login can call with a signed request containing the user's UID. This triggers a logout request via the `BackdoorLogoutUtility`.
   - For **FindDeveloper**, this functionality is also simulated.
   - The path that One Login sends the logout request to in our application is `/auth/one-login/backchannel-logout`

4. **Passive Authentication**:
   - This was a planned feature where a user with an existing One Login session could load the Find service without a Find session and be seamlessly authenticated through passive authentication. This is not a feature that One Login have made available and so we must actively authenticate, which means the user must click Sign in and One Login will respond with the necessary response to sign the user into Find.

---

## OmniAuth Provider Configuration

Both **One Login** and **FindDeveloper** are registered with **OmniAuth** as providers in the Rails application, but their configurations differ based on the environment.

### Example Configuration for One Login (Production)

In **production**, we use the `govuk_one_login` provider.

```
provider :govuk_one_login,
    name: :"one-login",        # This sets the :provider variable in /auth/:provider
    path_prefix: "/auth"       # This sets the /auth prefix in /auth/:provider
```

### Example Configuration for FindDeveloper (Non-Production)

In **non-production environments** (e.g., QA, local development), we use the `find_developer` provider, which is a custom OmniAuth strategy.

```
provider :find_developer,
    name: :"find-developer",   # This sets the :provider variable in /auth/:provider
    path_prefix: "/auth"       # This sets the /auth prefix in /auth/:provider
```

### Handling Authentication Failures

When either provider returns an error, the app redirects to `/auth/failure`. The error messages are passed as query parameters (e.g., `/auth/failure?error_code=invalid_request&error_description=client%20registry%20does%20not%20contain%20post_logout_redirect_uri&state=W4T5a-HP_RkXh3tCSJwH8GqXG9bgl_rgT1U3OphGw39GbyVfsO8HCs8R2inxsFey`). The application renders the error view (`errors/omniauth`) for the candidate interface.


---

## Environment-Specific Setup

We use the Settings to configure our One Login local configuration. The main configuration is in `config/settings.yml` and all environments inherit conifiguration from here in the `config/settings/*` directory. We can enable or disable One Login for QA or review apps here.


### **One Login (Production)**
- **Production Environment**: The app uses the **One Login** provider.
- **Configuration**: One Login is configured in the **One Login Admin Tool**.

### **FindDeveloper (Non-Production)**
- **Non-Production Environments**: The **FindDeveloper** provider is used for development, QA, and review apps.
- **Configuration**: **FindDeveloper** is set up using a custom OmniAuth strategy designed to simulate the One Login authentication flow without connecting to the actual One Login service.

#### Environments Using One Login and FindDeveloper

- **Production**: Uses the **One Login** provider.
- **QA**: Uses the **FindDeveloper** provider (or **One Login** can be enabled for QA if required).
- **Review Apps**: Requires configuration for each review app using **FindDeveloper** or **One Login**.

---

## One Login Admin Tool

We use the **One Login Admin Tool** to configure and manage One Login integrations, but we do not have direct access to production configurations. Changes to production settings must be requested from One Login.

### Steps to Set Up One Login for Non-Production Environments

If you want to enable One Login in environments such as QA, a review app, or locally, follow these steps:

1. Create a [One Login Admin Tool Integration](https://admin.sign-in.service.gov.uk/sign-in/enter-email-address).
2. Generate a [public-private key pair](https://docs.sign-in.service.gov.uk/before-integrating/set-up-your-public-and-private-keys/#create-a-key-pair):
   - Ensure that this is still the recommended method by checking the latest docs.
   - Generate the key pair using:
     ```
     openssl genpkey -algorithm RSA -out private_key.pem -pkeyopt rsa_keygen_bits:2048
     openssl rsa -pubout -in private_key.pem -out public_key.pem
     ```

3. In the **One Login Admin Tool**, complete the following:
   - Set the **Redirect URL**: `https://HOSTNAME/auth/one-login/callback`
   - Set the **Backchannel logout URL**: `https://HOSTNAME/auth/one-login/backchannel-logout`
   - Upload the **Public Key PEM** file.

1. Set the necessary values in the review environment:
   - Run `make review edit-app-secrets`.
   - Set `ONE_LOGIN_PRIVATE_KEY`.
   - Set `ONE_LOGIN_CLIENT_ID`.



### One Login Header

The header in Find is displays the Sign in button when the user is not signed in and displays the links to the users One Login profile and a Sign out button when the user is signed in. The header is defined in `Govuk::OneLoginHeaderComponent`.
The javascript and css is copied from the header maintained by One Login team.

The current version we use is v3.0.1.

https://github.com/govuk-one-login/service-header


### Setup in QA

Public Key 
```
MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAqiJ/SiyVGRWzdQZSp4wViLtshGUclpyxoc8yw0N5/vZqt1N3XuN/WKiqsI9iI362/3MIfbUnrkc9q39aE9O6nDNkHchrscas5ri7n0rRiElKAi1QEHIaanH7kUbC8kg8v7ZTSzygbJOdNlRicMxUcaXqFLZjaWxs9Gog6D3A/yUaxTJih6ILQbrZ8KpMKyG/cl3BoAKrYpQeiVM0n0+kv2irLQitmm7D79uohxCyJYioWYEDUMLmrcMX42zm0fkoVfb6MBwk1Y0E69/B/hIczJHSER3z1roUPHLI67uqRJgjw04cqdRuBzYDWvWXeguk6mRpimMCqtdkBjpImuViqQIDAQAB
```
