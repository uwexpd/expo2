SecureHeaders::Configuration.default do |config|
  config.csp = {
    default_src: %w(https: 'self'),
    font_src: %w('self' data: https:),
    img_src: %w('self' https: data:),
    object_src: %w('none'),
    script_src: %w(https: 'self' 'unsafe-inline' *.googleapis.com),
    style_src: %w('self' https: 'unsafe-inline' *.googleapis.com)
  }

  config.cookies = {
    samesite: SecureHeaders::OPT_OUT
  }
end