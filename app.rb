require 'sinatra/base'
require 'sinatra/assetpack'
require 'rack-flash'
require 'erb'
require_relative 'lib/github'

class App < Sinatra::Base
  set :root, File.dirname(__FILE__)
  enable :sessions
  use Rack::Flash

  # Asset Pack.
  register Sinatra::AssetPack
  assets do
    serve '/js',     from: 'app/js'
    serve '/css',    from: 'app/css'

    css :app, ['/css/*.css']
    js :app,  ['/js/*.js']
  end

  user = User.new('EUIbugs', 'EUIbugs1')
  testbugs = Repository.new('EUIbugs', 'testbugs')
  # eui = Repository.new('Epicgrim', 'EUI')

  def missing_fields( response )
    missing = []
    if response && response['errors']
      response['errors'].each do |error|
        missing << error['field']
      end
    end
    return missing
  end

  def error?( name, response )
    return missing_fields(response).include?(name)
  end

  get '/' do
    erb :index, locals: { 
      issues: testbugs.get_issues,
      submitted: params['submitted'],
    }
  end

  post '/' do
    # params is the right format for .post_issue :)
    response = testbugs.post_issue( user, params )
    flash[:response] = response
    redirect '/'
  end
end