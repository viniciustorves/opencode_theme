require "opencode_theme/version"
require 'opencode_theme/base_service'

module OpencodeTheme

  NOOPParser = Proc.new {|data, format| {} }
  TIMER_RESET = 10
  PERMIT_LOWER_LIMIT = 3
  CONFIG_FILE = 'config.yml'

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


  def self.config
    @config ||= if File.exist? CONFIG_FILE
      config = YAML.load(File.read(CONFIG_FILE))
      config
    else
      puts "#{CONFIG_FILE} does not exist!" unless test?
      {}
    end
  end

  def self.config=(config)
    @config = config
  end


  def self.is_binary_data?(string)
    if string.respond_to?(:encoding)
      string.encoding == "US-ASCII"
    else
      ( string.count( "^ -~", "^\r\n" ).fdiv(string.size) > 0.3 || string.index( "\x00" ) ) unless string.empty?
    end
  end

  def self.path(type = nil)
    @path ||= config[:theme_id] ? "/api/themes/#{config[:theme_id]}/assets" : "/api/themes/assets"
#    @path ||= config[:theme_id] ? "/opencode/themes/#{config[:theme_id]}/assets" : "/opencode/themes/assets"
   # @path ||= config[:theme_id] ? "/api/themes/upfiles/#{config[:theme_id]}" : "/api/themes/upfiles"  if type == :get_asset
  end


  def self.ignore_files
    (config[:ignore_files] || []).compact.map { |r| Regexp.new(r) }
  end

  def self.whitelist_files
    (config[:whitelist_files] || []).compact
  end

end