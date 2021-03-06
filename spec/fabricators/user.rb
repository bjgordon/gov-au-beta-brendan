Fabricator(:user) do
  email { Fabricate.sequence(:email) { |i| "user-#{i}@some-agency.gov.au" } }
  password { "qwerty1234" }
  transient :is_admin, :author_of, :reviewer_of, :owner_of, :unconfirmed
  account_verified { true }
  phone_number { '0423456789' }
  bypass_tfa { true }

  after_build do |user, transients|
    if transients[:is_admin]
      user.add_role(:admin)
    end
    [:author_of, :reviewer_of, :owner_of].each do |role|
      if transients[role]
        Array.wrap(transients[role]).each do |section|
          user.add_role(role[0..-4], section)
        end
      end
    end

    if transients[:owner_of]
      Array.wrap(transients[:owner_of]).each do |section|
        user.add_role(:owner, section)
      end
    end

    if !transients[:unconfirmed]
      now = Time.now.utc
      user.confirmed_at = now
      user.confirmation_sent_at = now - 1.day
    end
  end
end

Fabricator(:totp_user, from: :user, class: :user) do
  after_build do |user, _|
    user.otp_secret_key = 'averysecretkey'
    user.save!
  end
end