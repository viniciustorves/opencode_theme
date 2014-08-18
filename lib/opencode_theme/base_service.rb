require 'httparty'

module OpencodeTheme
  include HTTParty
  @@current_api_call_count = 0
  @@total_api_calls = 40
  URL_API2 = "http://cronit.rafaeltakashi.com:9000"
  URL_API = "http://isilva.appthemes.ruby.dev.tray.intranet"

  def self.api_usage
    "[API Limit: #{@@current_api_call_count || "??"}/#{@@total_api_calls || "??"}]"
  end

  def self.check_config
  	 response = opencode_theme2.get("/opencode/check", :query => {:store => config[:store], :theme_id => config[:theme_id] })
   return {success: response.success?, response: JSON.parse(response.body)}
  end

  def self.theme_new(theme_base, theme_name)
    puts "theme_new=>#{theme_base}=>#{theme_name}"
    api = "Token token=#{config[:api_key]}_#{config[:password]}"

    response = opencode_theme.post("/api/themes", :body => {:theme => {:theme_base => theme_name, :name => theme_name}}.to_json,
                                                  :headers => { 'Content-Type' => 'application/json'}, :parser => NOOPParser)
    puts "opencode_theme---->#{opencode_theme.inspect}"
     puts "resposta criacao tema no commerce =>#{response.inspect}"
     assets   = response.code == 200 ? JSON.parse(response.body)["assets"] : {}
	 return {success: response.success?, assets: assets, response: JSON.parse(response.body)}
      #curl -H "Content-Type: application/json" -H 
      #{}"Authorization: Token token=6b59d38039568f78d357ee347d4af6a7_c8431afbef7d1f77fca7715fea1c407c" 
      #-d '{"theme": {"name": "takashi","theme_base": "default"}}' http://isilva.appthemes.ruby.dev.tray.intranet/api/themes  
#<HTTParty::Response:0x7fbf79ce3f20 parsed_response={}, @response=#<Net::HTTPOK 200 OK readbody=true>, 
#@headers={"content-type"=>["application/json; charset=utf-8"], 
#  "transfer-encoding"=>["chunked"], "connection"=>["close"], "status"=>["200 OK"], 
#  "x-frame-options"=>["ALLOWALL"], "www-authenticate"=>["realm=\"Application\""], 
#  "etag"=>["\"04a240ed829af73c16032691cfe41ea4\""], "cache-control"=>["max-age=0, private, must-revalidate"], 
#  "x-request-id"=>["235858de-9aa9-4194-871f-ebaae1a5686a"], "x-runtime"=>["0.013540"], 
#  "x-powered-by"=>["Phusion Passenger 4.0.42"], "date"=>["Thu, 14 Aug 2014 14:09:31 GMT"], 
#  "server"=>["nginx/1.6.0 + Phusion Passenger 4.0.42"]}>
#response=>{:success=>true, :assets=>nil, :response=>{"message"=>"Token de acesso inválido", "code"=>"00001", "status"=>401}}
#Create takashi_theme2 theme on store [10]

  end


  def self.theme_new_old(theme_base, theme_name)
      response = opencode_theme2.get("/opencode/theme/create", :query => {:theme_base => theme_name, :theme_name => theme_name}, :parser => NOOPParser)
      assets = response.code == 200 ? JSON.parse(response.body)["assets"] : {}
      return {success: response.success?, assets: assets, response: JSON.parse(response.body)}
  end


  def self.asset_list
    puts "asset_list=>"
    # HTTParty parser chokes on assest listing, have it noop
    # and then use a rel JSON parser.
    puts "buscando arquivos em=> #{path}"
    response = opencode_theme.get(path, :parser => NOOPParser)
    puts "response=>#{response.inspect}"
    puts "body=>#{response.body.inspect}"
    assets = response.code == 200 ? JSON.parse(response.body)["assets"].collect {|a| a['key'] } : {}
    assets
  end

#isilva [5:00 PM]5:00
#http://isilva.appthemes.ruby.dev.tray.intranet/api/themes/upfiles/38?key=/315169/themes/38/css/fonts/glyphicons-halflings-regular.svg
  def self.get_asset(asset)
    puts "get_asset=>#{asset}"
    puts "path =>#{path}"
    response = opencode_theme.get(path, :query => {:key => asset}, :parser => NOOPParser)
    puts "resposta =>#{response.inspect}"
    puts "resposta =>#{response.body.inspect}"
    # HTTParty json parsing is broken?
    asset = response.code == 200 ? JSON.parse(response.body) : {}
  #  asset['response'] = response
    asset
  end
 #curl -H "Content-Type: application/json" -H "Authorization: Toke" http://isilva.appthemes.ruby.dev.tray.intranet/api/themes/38/upfiles?path=/315169/themes/38/css/fonts/glyphicons-halflings-regular.svg
  def self.send_asset(data)
   response = opencode_theme.put(path, :body =>{:asset => data})
#    response = opencode_theme.get(path, :body => {:asset => data})
    response
  end

  def self.delete_asset(asset)
#    response = opencode_theme.delete(path, :body =>{:asset => {:key => asset}})
    response = opencode_theme.get(path, :body => {:asset => {:key => asset}})
    response
  end

  private
  def self.opencode_theme
    base_uri URL_API
    headers  "Authorization" => "Token token=#{config[:api_key]}_#{config[:password]}"
    OpencodeTheme
  end

  def self.opencode_theme2
  #  basic_auth config[:api_key], config[:password]
    base_uri URL_API2
    OpencodeTheme
  end

end