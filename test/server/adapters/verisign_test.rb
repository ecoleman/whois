require 'test_helper'

class ServerAdaptersVerisignTest < Test::Unit::TestCase

  def setup
    @definition = [:tld, ".foo", "whois.foo", {}]
    @klass  = Whois::Server::Adapters::Verisign
    @server = @klass.new(*@definition)
  end

  def test_query
    response = "No match for DOMAIN.FOO."
    expected = response
    @server.expects(:ask_the_socket).with("=domain.foo", "whois.foo", 43).returns(response)
    assert_equal expected,
                 @server.query("domain.foo").to_s
    assert_equal [Whois::Answer::Part.new(response, "whois.foo")],
                 @server.buffer
  end

  def test_query_with_referral
    referral = File.read(File.dirname(__FILE__) + "/../../testcases/referrals/crsnic.com.txt")
    response = "Match for DOMAIN.FOO."
    expected = referral + "\n" + response
    @server.expects(:ask_the_socket).with("=domain.foo", "whois.foo", 43).returns(referral)
    @server.expects(:ask_the_socket).with("domain.foo", "whois.tucows.com", 43).returns(response)
    assert_equal expected,
                 @server.query("domain.foo").to_s
    assert_equal [Whois::Answer::Part.new(referral, "whois.foo"), Whois::Answer::Part.new(response, "whois.tucows.com")],
                 @server.buffer
  end

end