class JiraController < ApplicationController
  def index
  	# set up the keyfile stuff
  	keyfile_path = "C:\\OpenSSL-Win64\\keys\\"
  	keyfile_root = "henrb028"
  	site_url = 'https://jira.disney.com'

  	# Read in the keys and configuration
 
	consumer_key = ""
	line = ""
	begin
		f =	File.open("#{keyfile_path}#{keyfile_root}.consumer")
		f.each do |line|
			consumer_key = consumer_key + line.chomp
		end
	rescue
		abort "Failure reading consumer file!\n#{$!}\n#{keyfile_path}#{keyfile_root}.consumer"
	ensure
		f.close unless f.nil?
	end

	opts={
	    consumer_key:       consumer_key,
	    site:               site_url,
	    scheme:             :header,
	    http_method:        :post,
	    signature_method:   'RSA-SHA1',
	    request_token_path: '/plugins/servlet/oauth/request-token',
	    authorize_path:     '/plugins/servlet/oauth/authorize',
	    access_token_path:  '/plugins/servlet/oauth/access-token'
	}

	private_key = ""
	line = ""
	begin
		f =	File.open("#{keyfile_path}#{keyfile_root}.key")
		f.each do |line|
			private_key = private_key + line
		end
	rescue
		abort "Failure reading private key file!\n#{$!}\n#{keyfile_path}#{keyfile_root}.key"
	ensure
		f.close unless f.nil?
	end

	consumer = OAuth::Consumer.new(opts[:consumer_key],private_key,opts)


  	# Read in the token and token secret

	token = ""
	line = ""
	begin
		f = File.open("#{keyfile_path}#{keyfile_root}.token")
		f.each do |line|
				token = token + line.chomp
			end
	rescue
		abort "Failure reading token file!\n#{$!}\n#{keyfile_path}#{keyfile_root}.token"
	ensure
		f.close unless f.nil?
	end

	tokensecret = ""
	line = ""
	begin
		f = File.open("#{keyfile_path}#{keyfile_root}.tokensecret")
		f.each do |line|
				tokensecret = tokensecret + line.chomp
			end
	rescue
		abort "Failure reading token secret file!\n#{$!}\n#{keyfile_path}#{keyfile_root}.tokensecret"
	ensure
		f.close unless f.nil?
	end

	access_token = OAuth::AccessToken.new(consumer, token, tokensecret)
	 
	 
	# This attaches the access token to a RestClient call
	RestClient.add_before_execution_proc do |req, params|
	  access_token.sign! req
	end
	 
  	# Call Jira and pass the response body straight through
  	begin
		render plain: RestClient.get("#{site_url}#{request.fullpath}")

	rescue
		render plain: "#{$!}\n    #{consumer_key}\n    #{token}\n    #{tokensecret}" 

	ensure
		RestClient.reset_before_execution_procs
	end

  	#render plain: "#{request.fullpath}"
  end
end
