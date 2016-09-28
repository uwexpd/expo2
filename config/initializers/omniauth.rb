if Rails.env == 'production'
  Rails.application.config.middleware.use OmniAuth::Builder do
      provider :shibboleth, {
        :debug => true,
        :extra_fields => [:"unscoped-affiliation", :entitlement, :uwNetID, :uwRegID]
      }
  end
end