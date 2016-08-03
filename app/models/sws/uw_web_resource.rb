class UwWebResource < ActiveResource::Base


  class << self    
    
    attr_accessor :caller_class
    
    # Attaches our cert, key, and CA file based on the config options in web_services.yml.
    def ssl_options
      check_cert_paths!
      @ssl_options ||= {
        :cert         => OpenSSL::X509::Certificate.new(File.open("#{Rails.root}/config/certs/#{config_options[:cert]}")),
        :key          => OpenSSL::PKey::RSA.new(File.open("#{Rails.root}/config/certs/#{config_options[:key]}")),
        :ca_file      => "#{Rails.root}/config/certs/#{config_options[:ca_file]}",
        :verify_mode  => OpenSSL::SSL::VERIFY_PEER
      }
    end
  
    # All configuration options are stored in RAILS_ROOT/config/web_services.yml. This allows us to use different
    # hosts, certs, etc. in different Rails environments.
    def config_options
      @config_options ||= Rails.application.config_for(:web_services).symbolize_keys
    end
    
    def headers
      { "x-uw-act-as" => 'expo' }
    end
    
    def sws_log(msg, time = nil)
      message = "  \e[4;33;1m#{self.class.to_s} Fetch"
      message << " (#{'%.1f' % (time*1000)}ms)" if time
      message << "\e[0m   #{msg}"
      Rails.logger.info message
    end
  
  end
  
  self.prefix = "https://#{UwWebResource.config_options[:host]}/student/#{Rails.application.config_for(:constants)["sws_version"]}"
  
  protected
  
  # Raises an error if the cert, key, or CA file does not exist.
  def self.check_cert_paths!
    raise ActiveResource::SSLError, "Could not find cert file" unless File.exist?("#{Rails.root}/config/certs/#{config_options[:cert]}")
    raise ActiveResource::SSLError, "Could not find key file" unless File.exist?("#{Rails.root}/config/certs/#{config_options[:key]}")
    raise ActiveResource::SSLError, "Could not find CA file" unless File.exist?("#{Rails.root}/config/certs/#{config_options[:ca_file]}")
    return true
  rescue => e
    puts Rails.logger.warn "[WARN] ActiveResource::SSLError: #{e.message}\n #{e.backtrace.try(:first)}"
    return false
  end
  
  
  
end