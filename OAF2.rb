# Set some defaults:
require 'oauth'
require 'restclient'

# OAuth Facilitator (OAF)
# Purpose: This provides a simple way to negotiate getting an authorized token
#          and token secret back from Jira's OAuth1.0 interface
#
# It is required that you have already generated your certificate with openssl and 
# extracted the relevant *.pem, *.key, and *.pcks8 files.
# For more info on this see: 
#   https://devcentral.disney.com/display/ATL/Integrations+with+JIRA+or+Confluence
# 
# A snippet from 10/23/2019 is included below:
#   openssl genrsa -out serviceaccount.key 1024
#   openssl req -newkey rsa:1024 -x509 -key serviceaccount.key -out serviceaccount.cer -days 365
#   openssl pkcs8 -topk8 -nocrypt -in serviceaccount.key -out serviceaccount.pcks8
#   openssl x509 -pubkey -noout -in serviceaccount.cer > serviceaccount.pem
#
# Regardless, you MUST follow the acces request process posted on the above DevCentral link.

puts "consumer key:"
consumer_key = gets.chomp
 
opts={
    consumer_key:       consumer_key,
    site:               'https://jira.disney.com/',
    scheme:             :header,
    http_method:        :post,
    signature_method:   'RSA-SHA1',
    request_token_path: '/plugins/servlet/oauth/request-token',
    authorize_path:     '/plugins/servlet/oauth/authorize',
    access_token_path:  '/plugins/servlet/oauth/access-token'
}

puts "Path for key files:"
key_file_path = gets.chomp

# Test for trailing \ and append if it is missing.
unless key_file_path.match(/\\$/)
	key_file_path = "#{key_file_path}\\"
end

puts "private key file name (*.key):"
private_key_file = gets.chomp
# take the private key filename and strip the extention 
consumer_file = private_key_file.split(".")[0]
token_file = private_key_file.split(".")[0]
tokensecret_file = private_key_file.split(".")[0]

begin
	f = File.open("#{key_file_path}#{consumer_file}.consumer", "w")
	f.puts consumer_key
rescue
	abort "Failure writing #{key_file_path}#{token_file}.consumer\n#{$!}"
ensure
	f.close unless f.nil?
end

private_key = ""
line = ""
begin
	File.open("#{key_file_path}#{private_key_file}").each do |line|
		private_key = private_key + line
	end
rescue
	abort "Failure reading #{key_file_path}#{private_key_file}\n#{$!}"
end

consumer = OAuth::Consumer.new(opts[:consumer_key],private_key,opts)
 
# The first time we connect with this service we need to obtain an access token:
request_token = consumer.get_request_token
 
puts "If a browser window fails to open, visit the following link. When prompted by MyID to log in, use your service accounts credentials."
puts request_token.authorize_url

# for MacOS replace the string "start" with "open" below - Note to future Bruce: I tried to do this but I ran out of patience for figuring out what OS is running.
system("start", "#{request_token.authorize_url}")
puts
puts "Enter verifier code:"
 
oauth_verifier = gets.chomp
access_token = request_token.get_access_token(:oauth_verifier => oauth_verifier)
 
puts "This token and secret can be re-used to skip the verification step next time"
puts "Token: #{access_token.token}"
begin
	f = File.open("#{key_file_path}#{token_file}.token", "w")
	f.puts access_token.token
rescue
	abort "Failure writing #{key_file_path}#{token_file}.token\n#{$!}"
ensure
	f.close unless f.nil?
end

puts "Secret: #{access_token.secret}"
begin
	f = File.open("#{key_file_path}#{tokensecret_file}.tokensecret", "w")
	f.puts access_token.secret
rescue
	abort "Failure writing #{key_file_path}#{tokensecret_file}.token\n#{$!}"
ensure
	f.close unless f.nil?
end
 
 
# Subsequent connections, where you already have an access token and secret
#puts "Enter access token:"
#token = gets.chomp
#puts "Enter access token secret:"
#secret = gets.chomp
 
#access_token = OAuth::AccessToken.new(consumer, token, secret)
 

#This attaches your access token to a RestClient call
#RestClient.add_before_execution_proc do |req, params|
#  access_token.sign!(req)
#end
 
# Once you have your access token we can test some REST calls
#fullpath = "https://jira.disney.com/rest/api/2/project"
#begin
#	puts RestClient.get(fullpath)
#rescue
#	abort "#{$!} \n #{access_token.to_s}" 
#ensure
#	RestClient.reset_before_execution_procs
#end
