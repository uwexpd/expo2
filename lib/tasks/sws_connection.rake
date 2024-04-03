require 'net/http'
require 'net/https'
require 'uri'
require 'openssl'

desc "Run UW SWS connection"
task :uwsws => :environment do	

	uri = URI.parse('https://ws.api.uw.edu/student/v5/person/421D2010536E20642483D92F4B16AC7F.json')

	# Create an SSL context and set the desired SSL/TLS version
	ssl_context = OpenSSL::SSL::SSLContext.new
	ssl_context.ssl_version = :TLSv1 # Set the desired version here

	http = Net::HTTP.new(uri.host, uri.port)
	http.use_ssl = true	
	http.ssl_context = ssl_context if http.respond_to?(:ssl_context=)

	http.cert = OpenSSL::X509::Certificate.new(File.read("#{Rails.root}/config/certs/expo.uaa.washington.edu.ic.crt"))
	http.key = OpenSSL::PKey::RSA.new(File.read("#{Rails.root}/config/certs/expo.uw.edu.key"))
	
	http.ca_file = "#{Rails.root}/config/certs/uwca.pem"
	http.verify_mode = OpenSSL::SSL::VERIFY_NONE #VERIFY_NONE

	request = Net::HTTP::Get.new(uri.path)

  response = http.request(request)
  puts "HTTP Status Code: #{response.code}"
  puts "Response Body: #{response.body}"

end


task :tls_version => :environment do	
	require 'socket'

	# Create an SSL context
	context = OpenSSL::SSL::SSLContext.new

	# Establish a connection to a server (e.g., www.example.com)
	socket = TCPSocket.new('ws.api.uw.edu', 443)

	# Wrap the socket with SSL/TLS
	ssl_socket = OpenSSL::SSL::SSLSocket.new(socket, context)
	ssl_socket.connect
	
	# Inspect SSL/TLS context
	puts "SSL/TLS Context Information:"
	ssl_socket.context.instance_variables.each do |ivar|
  value = ssl_socket.context.instance_variable_get(ivar)
  	puts "#{ivar}: #{value.inspect}"
	end

	# Close the connection
	ssl_socket.close

end

# How to Check the TLS Version in OS
# openssl s_client -connect ws.api.uw.edu:443 -tls1
# openssl ciphers -v | awk '{print $2}' | sort | uniq
# SSLv3
# openssl ciphers -vTLSv1.2

# check what openssl RVM use: 
# ruby -ropenssl -e "puts OpenSSL::OPENSSL_VERSION" 
# OpenSSL 1.1.1m  14 Dec 2021

# Use curl to test
#curl --cert /Users/joshlin/Sites/expo2/config/certs/expo.uaa.washington.edu.ic.crt --key /Users/joshlin/Sites/expo2/config/certs/expo.uw.edu.key https://ws.api.uw.edu/student/v5/person/421D2010536E20642483D92F4B16AC7F.json
# Production server:
#curl --cert /usr/local/apps/expo2/current/config/certs/expo.uaa.washington.edu.ic.crt --key /usr/local/apps/expo2/current/config/certs/expo.uw.edu.key https://ws.api.uw.edu/student/v5/person/899DE73E18B3764FAACE327C45060B50.json
#=> Successfully get the search result
