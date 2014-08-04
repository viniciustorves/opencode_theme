require 'httparty'

module OpencodeTheme
  include HTTParty
  @@current_api_call_count = 0
  @@total_api_calls = 40
  URL_API = "http://cronit.rafaeltakashi.com:9000"

  def self.api_usage
    "[API Limit: #{@@current_api_call_count || "??"}/#{@@total_api_calls || "??"}]"
  end

  def self.check_config
  	return opencode_theme.get("/opencode/check", :query => {:store => config[:store], :theme_id => config[:theme_id] }, :parser => NOOPParser)
  end

  def self.theme_new(theme_base, theme_name)
     response = opencode_theme.get("/opencode/theme/create", :query => {:theme_base => theme_name, :theme_name => theme_name}, :parser => NOOPParser)
     assets   = response.code == 200 ? JSON.parse(response.body)["assets"] : {}
	 return {success: response.success?, assets: assets, response: JSON.parse(response.body)}
  end

  def self.asset_list
    # HTTParty parser chokes on assest listing, have it noop
    # and then use a rel JSON parser.
    response = opencode_theme.get(path, :parser => NOOPParser)
    assets = JSON.parse(response.body)["assets"].collect {|a| a['key'] }
    assets
  end

  def self.get_asset(asset)
    response = opencode_theme.get(path, :query => {:asset => {:key => asset}}, :parser => NOOPParser)
    # HTTParty json parsing is broken?
    asset = response.code == 200 ? JSON.parse(response.body)["asset"] : {}
    asset['response'] = response
    asset
  end

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
    basic_auth config[:api_key], config[:password]
    base_uri URL_API
    OpencodeTheme
  end

end