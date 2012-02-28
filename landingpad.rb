require 'rubygems'
require 'sinatra/base'
require 'uri'
require 'mongo'
require 'erb'
require 'json'


class LandingPad < Sinatra::Base
  set :static, true
  set :public_folder, 'public'


  configure do
    $app_url = ENV['APP_URL'] || "http://localhost:3456/"

    # Admin settings - used to access contacts
    $admin_acct_name = ENV['ADMIN_ACCT_NAME'] || 'admin'
    $admin_acct_passwd = ENV['ADMIN_ACCT_PASSWD'] || 'admin'

    # Page settings - used to configure your landing page
    $page_title = ENV['PAGE_TITLE'] || 'LandingPad.rb | Just add water landing pages'
    $app_title = ENV['APP_TITLE'] ||  'LandingPad.rb'
    $app_summary = ENV['APP_SUMMARY'] || 'Get a page up and running in minutes and start collecting contacts immediately!'
    #your google analyics tracking key, if applicable
    $google_analytics_key = ENV['GOOGLE_ANALYTICS_KEY'] || 'UA-XXXXXX-X'

    $bg_color = ENV['BGCOLOR'] || '#FFF'
    $app_title_color = ENV['APP_TITLE_COLOR'] || '#FFF'
    #see http://code.google.com/webfonts for available fonts
    $app_title_font = ENV['APP_TITLE_FONT'] || 'Open Sans'

    #social network settings, for sharing the page post signup
    $social_twitter = ENV['SOCIAL_TWITTER']

    # Database settings - do NOT change these
    mongo_url = ENV['MONGOHQ_URL']

    # only hook up mongo if we have a url, this means subscribing and contacts won't work locally
    unless mongo_url.nil?
      uri = URI.parse(mongo_url)
      conn = Mongo::Connection.from_uri(mongo_url)
      db = conn.db(uri.path.gsub(/^\//, ''))
      $collection = db.collection("contacts")
    end
  end

  helpers do
    include Rack::Utils

    def u text
      escape text
    end

    def protected!
      unless authorized?
        response['WWW-Authenticate'] = %(Basic realm="Restricted Area")
        throw(:halt, [401, "Not authorized\n"])
      end
    end

    def authorized?
      @auth ||=  Rack::Auth::Basic::Request.new(request.env)
      @auth.provided? && @auth.basic? && @auth.credentials && @auth.credentials == [$admin_acct_name, $admin_acct_passwd]
    end
  end

  get '/' do
    erb :index
  end

  get '/config' do
    protected!
    erb :config
  end

  get '/contacts' do
    protected!
    @contacts = $collection.find()
    erb :contacts
  end

  post '/subscribe' do
    content_type :json
    contact = params[:contact]
    contact_type = contact.start_with?("@") ||
                  !contact.include?("@") ? "Twitter" : "Email"

    doc = {
      "name"    => contact,
      "type"    => contact_type,
      "referer" => request.referer,
    }

    $collection.insert(doc)
      {"success" => true, "type" => contact_type}.to_json
    end
end
