ENV['RACK_ENV'] ||= 'development'

require 'sinatra'
require 'sinatra/cross_origin'
require 'json'
require 'dotenv'
require 'rest-client'
require 'sprockets'
require 'uglifier'
require 'sass'

require_relative 'controllers/index_controller'
require_relative 'controllers/list_controller'

class User
  attr_accessor :username, :profile_picture, :id, :full_name

  def initialize(object)
    @username = object.username
    @profile_picture = object.profile_picture
    @id = object.id
    @full_name = object.full_name
  end
end

class InstaFollowers < Sinatra::Base
  Dotenv.load
  enable :cross_origin

  set :root, File.dirname(__FILE__)
  set :haml, :format => :html5
  set :environment, Sprockets::Environment.new

  environment.append_path "assets/stylesheets"
  environment.append_path "assets/javascripts"

  environment.js_compressor  = :uglify
  environment.css_compressor = :scss

  register Sinatra::InstaFollowers::Controllers::IndexController
  register Sinatra::InstaFollowers::Controllers::ListController  

  get "/assets/*" do
    env["PATH_INFO"].sub!("/assets", "")
    settings.environment.call(env)
  end
end
