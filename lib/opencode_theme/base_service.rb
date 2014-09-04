require 'httparty'

module OpencodeTheme
  include HTTParty
  @@current_api_call_count = 0
  @@total_api_calls = 40
  URL_API = "https://opencode-alog2.tray.com.br"
  #URL_API = "http://isilva.appthemes.ruby.dev.tray.intranet"

  def self.api_usage
    "[API Limit: #{@@current_api_call_count || "??"}/#{@@total_api_calls || "??"}]"
  end

  def self.check_config
    response = opencode_theme.post("/api/check", :query => {:theme_id => config[:theme_id] })
    return {success: response.success?, response: JSON.parse(response.body)}
  end

  def self.publish(theme_id)
    response = opencode_theme.post("/api/themes/publish", :body => {:theme_id => theme_id} , :parser => NOOPParser)
    return {success: response.success?, response: JSON.parse(response.body)}
  end

  def self.theme_delete(theme_id)
    response = opencode_theme.delete("/api/themes/#{theme_id}", :parser => NOOPParser)
    return {success: response.success?, response: JSON.parse(response.body)}
  end

  def self.theme_new(theme_base, theme_name)
    response = opencode_theme.post("/api/themes", :body => {:theme => {:theme_base => theme_name, :name => theme_name}}.to_json,
      :headers => { 'Content-Type' => 'application/json'}, :parser => NOOPParser)
     assets   = response.code == 200 ? JSON.parse(response.body)["assets"] : {}
     return {success: response.success?, assets: assets, response: JSON.parse(response.body)}
  end

  def self.asset_list
    response = opencode_theme.get(path, :parser => NOOPParser)
    assets = response.code == 200 ? JSON.parse(response.body)["assets"].collect {|a| a['key'] } : {}
    assets
  end

  def self.get_asset(asset)
      response = opencode_theme.get(path, :query => {:key => asset}, :parser => NOOPParser)
      asset = JSON.parse(response.body)
      asset
  end

  def self.send_asset(data)
    response = opencode_theme.put(path, :body => data)
    response
  end

  def self.delete_asset(asset)
    response = opencode_theme.delete(path, :body => {:key => asset})
    response
  end

private
  def self.opencode_theme
    base_uri URL_API
    headers  "Authorization" => "Token token=#{config[:api_key]}_#{config[:password]}"
    OpencodeTheme
  end

end