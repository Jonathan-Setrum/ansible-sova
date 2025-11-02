require "yaml"
require "ipaddr"
require "resolv"
require 'net/http'
require "open-uri"

USER_AGENT="SovaScan"

# https://www.cloudflare.com/ips
def cloudflare?(ip)
  %w{
199.27.128.0/21
173.245.48.0/20
103.21.244.0/22
103.22.200.0/22
103.31.4.0/22
141.101.64.0/18
108.162.192.0/18
190.93.240.0/20
188.114.96.0/20
197.234.240.0/22
198.41.128.0/17
162.158.0.0/15
104.16.0.0/12
  }.any?{|r| IPAddr.new(r).include? ip }
end

def get_http_response(domain, path="/")
  http = Net::HTTP.start(domain)
  response = http.head(path, "User-Agent" => USER_AGENT)
  http.finish

  return response
end

def get_domain(url)
  URI.parse(url).hostname rescue nil
end

def find_wp_content(url)
  open(url, "User-Agent" => USER_AGENT){|f|
    f.read.match(%r{https?://.*?wp-content/})[0]
  } rescue nil
end

def get_real_url(meta)
  result = {}

  default_url = "http://#{meta[:default_hostname]}"
  registered_url = "http://#{meta[:hostname]}"

  headers = get_http_response(meta[:default_hostname])
  pingback_url = headers["x-pingback"]

  if pingback_url.is_a? String and pingback_url.length > 8
    result[:wp_url] = pingback_url.slice(0, pingback_url.index("/", 7))
  end

  if result[:wp_url].nil?
    hostname = if headers["Location"]
                 get_domain(headers["Location"])
               elsif not meta[:hostname].end_with? "sova.bz"
                 meta[:hostname]
               else
                 nil
               end
    if hostname.nil?
      result[:wp_url] = default_url
    elsif (dns_ip = Resolv.getaddress(hostname) rescue nil) == meta[:ip] or cloudflare?(dns_ip)
      result[:wp_url] = registered_url
    end
  end

  result[:wp_url] ||= default_url

  unless get_http_response(meta[:default_hostname], "/wp-content/").is_a? Net::HTTPSuccess
    content_dir = find_wp_content(result[:wp_url])
    if content_dir
      (meta[:cdn] || []).each do |cdn_domain|
        if content_dir.to_s.include?(cdn_domain)
          content_dir = URI.parse(content_dir)
          content_dir.host = URI.parse(result[:wp_url]).host
        end
      end
      result[:wp_content_dir] = content_dir.to_s
    end
  end

  return result
rescue
  warn $!.inspect
  warn "##{meta[:id]} #{meta[:ip]} #{meta[:default_hostname]}"
  return {}
end

if __FILE__ == $PROGRAM_NAME
  REMARKS_FILE = ENV.fetch("REMARKS_FILE", "#{Dir.pwd}/remarks.yml")
  BASE_FILE = ENV.fetch("BASE_FILE", "#{Dir.pwd}/urls.yml")
  if File.exists? REMARKS_FILE
    remarks = YAML.load_file(REMARKS_FILE)
  else
    remarks = {}
  end

  parallel = 100
  @meta = []
  queue = Queue.new
  YAML.load_file(BASE_FILE).each do |meta|
    exception = remarks[meta[:ip]] || {}
    queue.push(meta.merge(exception))
  end
  threads = []
  parallel.times do
    threads << Thread.start do
      while !queue.empty?
        meta = queue.pop
        other = get_real_url(meta)
        @meta << meta.merge(other)
      end
    end
  end
  threads.each {|t| t.join }
  File.write(BASE_FILE, @meta.sort{|a, b| a[:id].to_i <=> b[:id].to_i }.to_yaml)
end
