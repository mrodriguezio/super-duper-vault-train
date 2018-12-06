require 'json'
require 'net/http'

def get_consul_stable_url(os='linux', arch='amd64')
    url = 'https://releases.hashicorp.com/consul/index.json'
    begin
        response = Net::HTTP.get_response(URI.parse(url))
        url = response['location']
    end while response.is_a?(Net::HTTPRedirection)
    versions = JSON.parse(response.body)['versions']
    stable_versions = versions.select do |key,item| !(key.to_s.include? 'rc' or key.to_s.include? 'beta') end
    latest_version = stable_versions.max_by{|key,item| key}
    linux_amd64 = latest_version[1]['builds'].select do |item| (item['os'] == os and item['arch'] == arch) end
    return linux_amd64[0]['url']
end
