FactoryBot.define do
  factory :session do
    user_agent { "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36" }
    ip_address { "192.169.1.42" }
    id_token { "b6a0000c637cc63c83aa5ada9f49fc72" }
    session_key { "46f991ab353648507017f0aca1de9563019c583c6d0c558d191454e13e886096" }
    sessionable { build(:candidate) }
    data { {} }
  end
end
