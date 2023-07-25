# Be sure to restart your server when you modify this file.

Rails.application.config.session_store :cookie_store, {
	key: '_expo2_session',
	expire_after: 2.days
	# domain: :all,
    # same_site: :none,
    # secure: :true,
    # tld_length: 2
}