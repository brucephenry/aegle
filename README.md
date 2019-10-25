# README for Aegle

# About
Aegle is a (very) thin rails server to handle proxying unauthenticated http requests to OAuth1.0 authenticated https requests
so that Power Query can ingest data from OAuth1.0 services like Disney's Enterprise Jira (https://jira.disney.com). Aegle was 
built super quickly as a rails app because I didn't want to deal with getting all of the request handling crap sorted out in 
a basic ruby app using httpd or whatever.

## Design
The basic design is that a single global route takes everything and passes it to the index method on the one controller.
That method handles all of the proxying and bypasses views by calling render plain: directly, passing through whatever was 
returned by the call to the external OAuth1.0 API. XML, JSON, HTML, cat gifs, it don't care. It just straight passes it through.

The 3 files that count for reals are:
* routes.rb
* jira_controller.rb (you will need to edit this to replace my key file names and paths with yours)
* OAF2.rb (found in the root of this application is a utility program)

# To Do
* Break OAF out into its own repo.
* Write some damned tests!
* Move the key files filenames & path to a configuration file (e.g. application.rb).
* Add rescue clauses to the key file reads to force server aborts if the keys cannot be read.
* Add a startup call to the controller to get back the jira version and if this fails abort the server.
* Make the proxy service a commandline argument when starting the server (ie rails server service="https://jira.disney.com").

# Known Issues
* RACE CONDITION - Placing more than one request at a time will cause badness.
* Some errors are not handled gracefully and tend to return unexpected JSON payloads. The symptom in Power Query is that it
reports "unexpected spaces" at the end of the JSON. Go figure. Usually this is due to a misconfigured query in your data source.

# Examples
Once the server is running, you should be able to call things like http://localhost:3000/rest/api/2/project and it will send
the request to the server and return your payload.

# Details
* Ruby version
ruby 2.6.4p104 or later

* System dependencies
Rails 6.0.0 or later

* Configuration
Needs acces to the folder in which your relevant key files for OAuth are located.
These key files can be generated using the OAuth Facilitator v2 (OAF2) found in the same directory as this README.

* Database creation
None

* Database initialization
None

* How to run the test suite
LOL

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions
bundle install
rails server

# Aegle? WTF?
Aegle, daughter of the titan Atlas. Jira... Atlassian... get it?
Sigh... never mind.