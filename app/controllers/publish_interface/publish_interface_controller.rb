module PublishInterface
  class PublishInterfaceController < ApplicationController
    layout "publish_interface"

    def current_user
      @current_user ||= begin
                          old_publish_cookies = cookies[:_publish_teacher_training_courses_session]

                          if old_publish_cookies.present?
                            cookie_payload = decrypt_cookie old_publish_cookies
                            decoded_stored_value = Base64.decode64 cookie_payload["_rails"]["message"]
                            stored_value = JSON.parse decoded_stored_value

                            email_from_old_publish = stored_value["auth_user"]["uid"]
                            User.find_by(email: email_from_old_publish)
                          else
                            User.find_by(email: user_session&.email)
                          end
                        end
    end

    def authenticated?
      current_user.present?
    end

    def decrypt_cookie(cookie)
      cookie = URI.unescape(cookie)
      data, iv, auth_tag = cookie.split("--").map do |v|
        Base64.strict_decode64(v)
      end
      cipher = OpenSSL::Cipher.new("aes-256-gcm")

      # Compute the encryption key
      secret_key_base = Rails.application.secret_key_base
      secret = OpenSSL::PKCS5.pbkdf2_hmac_sha1(secret_key_base, "authenticated encrypted cookie", 1000, cipher.key_len)

      # Setup cipher for decryption and add inputs
      cipher.decrypt
      cipher.key = secret
      cipher.iv  = iv
      cipher.auth_tag = auth_tag
      cipher.auth_data = ""

      # Perform decryption
      cookie_payload = cipher.update(data)
      cookie_payload << cipher.final
      JSON.parse cookie_payload
    end
  end
end
