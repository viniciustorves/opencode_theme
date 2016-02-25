require 'httparty'
module OpencodeTheme
  include HTTParty
  default_options.update(verify: false)
  @@current_api_call_count = 0
  @@total_api_calls = 40
  URL_API = 'https://opencode.tray.com.br'

  def self.api_usage
    "[API Limit: #{@@current_api_call_count || '??'}/#{@@total_api_calls || '??'}]"
  end

  def self.check_config
    response = opencode_theme.post('/api/check', query: { theme_id: config[:theme_id],
                                                          gem_version: OpencodeTheme::VERSION })
    { success: response.success?, response: JSON.parse(response.body) }
  end

  def self.list
    response = opencode_theme.get('/api/list', query: { gem_version: OpencodeTheme::VERSION })
    { success: response.success?, response: JSON.parse(response.body) }
  end

  def self.clean
    response = opencode_theme.post('/api/clean_cache', query: { theme_id: config[:theme_id],
                                                                gem_version: OpencodeTheme::VERSION })
    { success: response.success?, response: JSON.parse(response.body) }
  end

  def self.theme_delete(theme_id)
    response = opencode_theme.delete("/api/themes/#{theme_id}", parser: NOOPParser, query: { gem_version: OpencodeTheme::VERSION })
    { success: response.success?, response: JSON.parse(response.body) }
  end

  def self.theme_new(theme_base, theme_name)
    response = opencode_theme.post('/api/themes',
                                   query: { gem_version: OpencodeTheme::VERSION },
                                   body: { theme: { theme_base: theme_name, name: theme_name, gem_version: OpencodeTheme::VERSION } }.to_json,
                                   headers: { 'Content-Type' => 'application/json'},
                                   parser: NOOPParser )
    assets = response.code == 200 ? JSON.parse(response.body)["assets"] : {}
    { success: response.success?, assets: assets, response: JSON.parse(response.body) }
  end

  def self.asset_list
    response = opencode_theme.get(path, parser: NOOPParser, query: { gem_version: OpencodeTheme::VERSION })
    assets = response.code == 200 ? JSON.parse(response.body)['assets'].collect {|a| a['key'][1..a['key'].length] } : response.body
    assets
  end

  def self.get_asset(asset)
    response = opencode_theme.get(path, query: { key: "/#{asset}", gem_version: OpencodeTheme::VERSION }, parser: NOOPParser)
    asset = response.code == 200 ? JSON.parse(response.body) : JSON.parse(response.body)
    asset
  end

  def self.send_asset(data)
    data[:gem_version] = OpencodeTheme::VERSION
    response = opencode_theme.put(path, body: data)
    response
  end

  def self.delete_asset(asset)
    response = opencode_theme.delete(path, body: { key: "/#{asset}" }, query: { key: "/#{asset}", gem_version: OpencodeTheme::VERSION })
    response
  end

  private

  def self.opencode_theme
    base_uri URL_API
    headers "Authorization" => "Token token=#{config[:api_key]}_#{config[:password]}"
    OpencodeTheme
  end
end
