require 'test/unit'
require 'fileutils'
require 'net/http'

require 'autowebreplay'
require 'webmock'

class AutowebreplayTest < Test::Unit::TestCase
  def setup
    proj_root = File.join(File.dirname(__FILE__), '..')
    full_cache_dir = File.join(proj_root, Autowebreplay.cache_dir)
    FileUtils.rm_rf(full_cache_dir)
    
    @request_signature = WebMock::RequestSignature.new('GET', 'http://www.google.com/')
    @response = WebMock::Response.new(:body => 'some specific body')
  end
  
  def test_should_have_cache_dir
    assert_equal '.autowebreplay', Autowebreplay.cache_dir
  end
  
  def test_should_create_cache_dir_as_needed
    Autowebreplay.save(@request_signature, @response)
    
    assert File.directory?(Autowebreplay.cache_dir), 
           'cache dir should exist and be directory'
  end
  
  def test_should_create_response_file_using_domain_and_hashed_signature_for_file_name
    Autowebreplay.save(@request_signature, @response)
    
    files = Dir[File.join(Autowebreplay.cache_dir, '*')]
    assert_equal 1, files.size
    
    file = files.first
    domain, hash = File.basename(file).split(Autowebreplay::FILE_DELIM)
    assert_equal 'www.google.com', domain
    assert_equal @request_signature.to_s.hash.to_s, hash
  end
  
  def test_should_be_able_to_look_up_saved_response
    Autowebreplay.save(@request_signature, @response)
    
    new_request_sig = WebMock::RequestSignature.new('GET', 'http://www.yahoo.com/')
    assert_nil Autowebreplay.lookup(new_request_sig)
    
    assert_equal @response, Autowebreplay.lookup(@request_signature)
  end
  
  def test_should_return_file_contents_on_subsequent_requests
    the_req = lambda {Net::HTTP.get_response('www.google.com', '/')}
    resp = the_req.call
    
    WebMock.disable_net_connect! # requests going to net will raise error
    
    saved_resp = the_req.call
    
    assert_equal resp.body, saved_resp.body
    
    # set-cookie gets normalized and the order might change so ignore it here
    headers, saved_headers = [resp.to_hash, saved_resp.to_hash]
    [headers, saved_headers].each {|h| h.delete('set-cookie')}
    assert_equal headers, saved_headers
  end
end
