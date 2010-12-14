require 'webmock'

module Autowebreplay
  FILE_DELIM = '+'
  class << self
    # a fancier individual than myself might make this configurable
    # for now a monkey patch would do the trick
    def cache_dir
      ".#{to_s.downcase}"
    end
    
    def save(request_signature, response)
      create_cache_dir!
      
      File.open(filename(request_signature), 'w') do |f|
        f << Marshal.dump(response)
      end
    end
    
    def lookup(request_signature)
      if File.exists?(f = filename(request_signature))
        Marshal.load(File.read(f))
      end
    end
    
    private
    
    def filename(request_signature)
      filename = [request_signature.uri.host, 
                  request_signature.to_s.hash.to_s].join(Autowebreplay::FILE_DELIM)
      File.join(cache_dir, filename)
    end
    
    def create_cache_dir!
      unless File.exists?(cache_dir)
        Dir.mkdir(cache_dir)
      end
    end
  end
end

WebMock.allow_net_connect!
WebMock.after_request(:real_requests_only => true)  do |request_signature, response|
  Autowebreplay.save(request_signature, response)
end

lookup_response = lambda do |request_signature|
  if resp = Autowebreplay.lookup(request_signature)
    hahs = [:headers, :body, :status, :exception].inject({}) do |h, prop|
      h[prop] = resp.send(prop)
      h
    end
    hahs
  end
end

WebMock::StubRegistry.instance.register_request_stub(WebMock::RequestStub.new(:any, /.*/)).
  with(&lookup_response).
  to_return(&lookup_response)
