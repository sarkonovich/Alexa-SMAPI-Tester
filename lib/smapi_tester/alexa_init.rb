class AlexaInit < Sinatra::Base
  set :views, File.dirname(__FILE__) + '/views'
  enable :inline_templates
  enable :sessions

  get '/retrieve_token' do
    erb :retrieve_token
  end

  post '/send_credentials' do
    client_id = params[:client_id]
    session[:client_secret] = params[:client_secret]
    session[:client_id] = client_id
    redirect_uri = params[:redirect_uri]
    scope = params[:scope]

    url = "https://www.amazon.com/ap/oa?client_id=#{client_id}&scope=alexa::ask:skills:test&response_type=code&redirect_uri=#{redirect_uri}"
    redirect url
  end

  get '/exit' do
    puts "============================================="
    puts "Closing WebServer and returning to terminal"
    puts "============================================="
    Process.kill('TERM', Process.pid)
    "Success! You can close this browser window and return to the terminal"
  end

  get '/callback' do
    if params[:error]
      halt params[:error_description]
    else
      code = params['code']
      id = session["client_id"]
      secret = session["client_secret"]
      response = `curl -v -X POST \
        -H "Content-Type":"application/x-www-form-urlencoded;charset=UTF-8" \
        -d "grant_type=authorization_code" \
        -d "code=#{code}" \
        -d "client_id=#{id}" \
        -d "client_secret=#{secret}" \
        -d "redirect_uri=http://localhost:4567/callback" \
        https://api.amazon.com/auth/o2/token`
      
      response = JSON.parse(response)
      if response["access_token"] && response["refresh_token"]
        File.open("#{CREDENTIALS}/.alexa_tester_tokens.json","w") do |f|
          f.write({"access_token"=>response["access_token"], "refresh_token"=>response["refresh_token"]}.to_json)
        end
        File.open("#{CREDENTIALS}/.client_credentials", "w") do |f|
          f.write({"id"=>id, "secret"=>secret}.to_json)
        end
        puts "============================================="
        puts "SUCCESS!"
        puts "============================================="
      else
        "Unable to retrieve tokens"
      end
      redirect '/exit'
    end
  end
end