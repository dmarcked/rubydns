#!/usr/bin/env ruby

# Copyright, 2012, by Samuel G. D. Williams. <http://www.codeotaku.com>
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

require 'minitest/autorun'

require 'rubydns'

class ResolverTest < MiniTest::Test
	def setup
		Celluloid.boot
	end
	
	def teardown
		Celluloid.shutdown
	end
	
	def test_basic_resolver
		resolver = RubyDNS::Resolver.new([[:udp, "8.8.8.8", 53], [:tcp, "8.8.8.8", 53]])
		
		response = resolver.query('google.com')
		assert_equal RubyDNS::Message, response.class
		
		response = resolver.query('foobar.oriontransfer.org')
		assert_equal Resolv::DNS::RCode::NXDomain, response.rcode
	end
	
	def test_broken_resolver
		resolver = RubyDNS::Resolver.new([])
		
		assert_raises RubyDNS::ResolutionFailure do
			response = resolver.query('google.com')
		end
	end
	
	class MockRequest
		attr :response
		
		def process_response!(response)
			@response = response
		end
	end
	
	#def test_dirty_packets_udp
	#	mock_request = MockRequest.new
	#	
	#	handler_class = Class.new{ include RubyDNS::Resolver::Request::UDPRequestHandler }
	#	handler = handler_class.new(mock_request, nil, nil)
	#	
	#	handler.receive_data("This is not a real message!")
	#	
	#	assert_equal Resolv::DNS::DecodeError, mock_request.response.class
	#end
	#
	#def test_dirty_packets_tcp
	#	mock_request = MockRequest.new
	#	
	#	handler_class = Class.new{ include RubyDNS::Resolver::Request::TCPRequestHandler }
	#	handler = handler_class.new(mock_request)
	#	
	#	data = "This is not a real message!"
	#	handler.receive_data([data.length].pack('n') + data)
	#	
	#	assert_equal Resolv::DNS::DecodeError, mock_request.response.class
	#end
	
	def test_addresses_for
		resolver = RubyDNS::Resolver.new([[:udp, "8.8.8.8", 53], [:tcp, "8.8.8.8", 53]])
		resolved_addresses = nil
		
		resolved_addresses = resolver.addresses_for("www.google.com.")
		
		assert resolved_addresses.count > 0
		
		address = resolved_addresses[0]
		assert address.kind_of?(Resolv::IPv4) || address.kind_of?(Resolv::IPv6)
	end
end
