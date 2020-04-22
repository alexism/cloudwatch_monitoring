

module IAM
  def self.role
    require 'net/http'
    require 'uri'

    uri = URI('http://169.254.169.254/latest/api/token/')
    req = Net::HTTP::Put.new(uri)
    req['X-aws-ec2-metadata-token-ttl-seconds'] = '60'
    res = Net::HTTP.start(uri.hostname, uri.port) {|http|
      http.request(req)
    }
    token = res&.body

    return unless token

    uri = URI('http://169.254.169.254/latest/meta-data/iam/security-credentials/')
    req = Net::HTTP::Get.new(uri)
    req['X-aws-ec2-metadata-token'] = token
    res = Net::HTTP.start(uri.hostname, uri.port) {|http|
      http.request(req)
    }
    res&.body
  end
end
