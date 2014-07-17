  require "opencode_theme/version"

require 'httparty'
module OpencodeTheme
  include HTTParty
  @@current_api_call_count = 0
  @@total_api_calls = 40

  NOOPParser = Proc.new {|data, format| {} }
  TIMER_RESET = 10
  PERMIT_LOWER_LIMIT = 3
  TIMBER_ZIP = "https://github.com/Shopify/Timber/archive/%s.zip"
  LAST_KNOWN_STABLE = "v1.1.0"

  URL_API = "http://cronit.rafaeltakashi.com:9000"
  #URL_API = "http://rendmine.dev"
  def self.manage_timer(response)
   # return unless response.headers['x-shopify-shop-api-call-limit']
  #  @@current_api_call_count, @@total_api_calls = response.headers['x-shopify-shop-api-call-limit'].split('/')
   # @@current_timer = Time.now if @current_timer.nil?
  end

  def self.test?
    ENV['test']
  end

  def self.critical_permits?
    @@total_api_calls.to_i - @@current_api_call_count.to_i < PERMIT_LOWER_LIMIT
  end

  def self.passed_api_refresh?
    delta_seconds > TIMER_RESET
  end

  def self.delta_seconds
    Time.now.to_i - @@current_timer.to_i
  end

  def self.needs_sleep?
    critical_permits? && !passed_api_refresh?
  end

  def self.sleep
    if needs_sleep?
      Kernel.sleep(TIMER_RESET - delta_seconds)
      @current_timer = nil
    end
  end

  def self.check_config
  	return opencode_theme.get("/opencode/check", :query =>{:store => config[:store], :theme_id => config[:theme_id] }, :parser => NOOPParser)
  end


  def self.theme_new(theme_base, theme_name)
  	   response = opencode_theme.get("/opencode/theme/create", :query =>{:theme_base => theme_name, :theme_name => theme_name}, :parser => NOOPParser)
		puts " response=>#{response.inspect}"
		puts " response.body=>#{response.body.inspect}"
	    assets = response.code == 200 ? JSON.parse(response.body)["assets"] : {}

		return {success: response.success?, assets: assets, response: JSON.parse(response.body)}
  end


def self.config
    @config ||= if File.exist? 'config.yml'
      config = YAML.load(File.read('config.yml'))
      config
    else
      puts "config.yml does not exist!" unless test?
      {}
    end
  end

  def self.config=(config)
    @config = config
  end

def self.ignore_files
    (config[:ignore_files] || []).compact.map { |r| Regexp.new(r) }
  end

  def self.whitelist_files
    (config[:whitelist_files] || []).compact
  end

  def self.is_binary_data?(string)
    if string.respond_to?(:encoding)
      string.encoding == "US-ASCII"
    else
      ( string.count( "^ -~", "^\r\n" ).fdiv(string.size) > 0.3 || string.index( "\x00" ) ) unless string.empty?
    end
  end

  def self.api_usage
    "[API Limit: #{@@current_api_call_count || "??"}/#{@@total_api_calls || "??"}]"
  end

 def self.asset_list
 	puts "asset_list=>path#{path}"
    # HTTParty parser chokes on assest listing, have it noop
    # and then use a rel JSON parser.
    response = opencode_theme.get(path, :parser => NOOPParser)
   # manage_timer(response)
puts "response=>#{response.inspect}"
    assets = JSON.parse(response.body)["assets"].collect {|a| a['key'] }
    puts "=>assets=>#{assets.inspect}"
    assets
    # Remove any .css files if a .css.liquid file exists
    #assets.reject{|a| assets.include?("#{a}.liquid") }
  end

  def self.get_asset(asset)

    puts "get_asset==>#{path}==>#{asset}"
    response = opencode_theme.get(path, :query =>{:asset => {:key => asset}}, :parser => NOOPParser)
    puts "response=>#{response.body.inspect}"
    manage_timer(response)

    # HTTParty json parsing is broken?
    asset = response.code == 200 ? JSON.parse(response.body)["asset"] : {}
    asset['response'] = response
    puts "resposta=>#{asset.inspect}"
    asset
  end

  def self.send_asset(data)
    puts "no path=>#{path}"
  	puts "opencode.send_asset=>#{data.inspect}"
         #opencode.send_asset=>{:key=>"assets/checkout.css", :value=>"ssas
    #response = opencode_theme.put(path, :body =>{:asset => data})

    response = opencode_theme.get(path, :body =>{:asset => data})
    manage_timer(response)
    response
  end

  def self.delete_asset(asset)
#    response = opencode_theme.delete(path, :body =>{:asset => {:key => asset}})
    response = opencode_theme.get(path, :body =>{:asset => {:key => asset}})
    manage_timer(response)
    puts "response=>#{response.inspect}"
    response
  end

  def self.path
    @path ||= config[:theme_id] ? "/opencode/themes/#{config[:theme_id]}/assets" : "/opencode/themes/assets"
  end

  private
  def self.opencode_theme
    basic_auth config[:api_key], config[:password]
    base_uri URL_API
    OpencodeTheme
  end

  def self.watch_until_processing_complete(theme)
    puts "watch_until_processing_complete"
    count = 0
    while true do
      Kernel.sleep(count)
      response = opencode_theme.get("/admin/themes/#{theme['id']}.json")
      theme = JSON.parse(response.body)['theme']
      return theme if theme['previewable']
      count += 5
    end
  end
end
