require 'rubygems'
require 'sinatra'
require 'uri'
require 'mongo'
require 'json'
require 'haml'
require 'sass'
require 'v8'
require 'hominid'
require 'net/http'

class LandingPad < Sinatra::Base
  set :static, true
  set :public_folder, 'public'


  configure do
    $app_url = ENV['APP_URL'] || "http://localhost:3456/"
    $hk_api_key = ENV['HK_API_KEY']
    $hk_app_name = ENV['HK_APP_NAME']

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

    #MailChimp api key to export contacts
    $mailchimp_api_key = ENV['mailchimp_api_key']
    $mailchimp_list = ENV['mailchimp_list']
    $mailchimp_username = ENV['mailchimp_username']
    $mailchimp_password = ENV['mailchimp_password']

    # Database settings - do NOT change these
    mongo_url = ENV['MONGOHQ_URL']

    # only hook up mongo if we have a url, this means subscribing and contacts won't work locally
    unless mongo_url.nil?
      match = mongo_url.match(/(.*):\/\/(.*):(.*)@(.*)/)
      $mongo_url = "#{match[1]}://username:password@#{match[4]}"
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

    def mailchimp_valid?
      return true if $mailchimp_api_key && $mailchimp_username && $mailchimp_password && $mailchimp_list
      false
    end

    def authorized?
      @auth ||=  Rack::Auth::Basic::Request.new(request.env)
      @auth.provided? && @auth.basic? && @auth.credentials && @auth.credentials == [$admin_acct_name, $admin_acct_passwd]
    end
  end

  get '/style.css' do
    scss :style, views: './public/css/'
  end

  get '/landingpad.js' do
    coffee :landingpad, views: './public/js/'
  end

  get '/' do
    haml :index
  end

  get '/config' do
    protected!
    haml :config, layout: :admin
  end

  post '/config/update' do
    protected!
    http = Net::HTTP.start('https://api.heroku.com')
    #req = Net::HTTP::Put.new("/apps/#{$hk_app_name}/config_vars")
    req = Net::HTTP::Put.new("/apps/landingpadrb/config_vars")
    req.add_field("Accept", "application/json")
    req.basic_auth '', '0d12fa51371432c129b640122ed5585877ee801f'#$hk_api_key
    req.set_form_data({"params" => {"KEY1" => "prout"}})
    #req.set_form_data("body=%7B%22KEY1%22%3A%20%22value1%22%7D")
    response = http.request(req)
    print response.body
  end

  get '/contacts' do
    protected!
    @contacts = $collection.find()
    haml :contacts, layout: :admin
  end

  get '/contacts/export/mailchimp' do
    protected!
    @contacts = $collection.find({type: 'Email'})
    if $mailchimp_api_key && $mailchimp_username && $mailchimp_password && $mailchimp_list
      hominid = Hominid::API.new $mailchimp_api_key, { username: $mailchimp_username, password: $mailchimp_password, secure: true }
      @contacts.each do |c|
        hominid.list_subscribe($mailchimp_list, c['name'], {}, 'html', false, true, false, false)
      end
    end
    redirect '/contacts'
  end

  get '/contacts/export/csv' do
    protected!
    @contacts = $collection.find()
    headers "Content-Disposition" => "attachment;filename=contacts.csv", "Content-Type" => "application/octet-stream"
    resutls = "Contact,Type,referer\n"
    @contacts.each do |c|
      resutls << "#{c['name']},#{c['type']},#{c['referer']}\n"
    end
    resutls
  end

  post '/subscribe' do
    content_type :json
    contact = params[:contact]
    contact_type = if contact.start_with?("@") then "Twitter" elsif  contact.include?("@") then "Email" else 'Other' end

    doc = {
      "name"    => contact,
      "type"    => contact_type,
      "referer" => request.referer,
    }

    $collection.insert(doc)
      {"success" => true, "type" => contact_type}.to_json
    end
end
