#!/usr/bin/ruby

# webrick.rb
# Procuratio Menu Server
#
# Created by Alexander v. Below on 26.04.10.
# Copyright 2010 AVB Software. All rights reserved.

%w{/Library/Frameworks/MacRuby.framework/Versions/0.5/usr/lib/ruby/site_ruby/1.9.0
/Library/Frameworks/MacRuby.framework/Versions/0.5/usr/lib/ruby/site_ruby/1.9.0/universal-darwin10.0
/Library/Frameworks/MacRuby.framework/Versions/0.5/usr/lib/ruby/site_ruby
/Library/Frameworks/MacRuby.framework/Versions/0.5/usr/lib/ruby/vendor_ruby/1.9.0
/Library/Frameworks/MacRuby.framework/Versions/0.5/usr/lib/ruby/vendor_ruby/1.9.0/universal-darwin10.0
/Library/Frameworks/MacRuby.framework/Versions/0.5/usr/lib/ruby/vendor_ruby
/Library/Frameworks/MacRuby.framework/Versions/0.5/usr/lib/ruby/1.9.0
/Library/Frameworks/MacRuby.framework/Versions/0.5/usr/lib/ruby/1.9.0/universal-darwin10.0}.each do |path|
	$: << path
end

require 'webrick'
include WEBrick

module WEBrick
  class HTTPRequest
    def read_request_line(socket)
      @request_line = read_line(socket, 1024) if socket
      if @request_line.size >= 1024 and @request_line[-1, 1] != LF
        raise HTTPStatus::RequestURITooLarge
      end
      @request_time = Time.now
      raise HTTPStatus::EOFError unless @request_line
      #if /^(\S+)\s+(\S+)(?:\s+HTTP\/(\d+\.\d+))?\r?\n/mo =~ @request_line
	  if /^(\S+)\s+(\S+)(?:\s+HTTP\/(\d+\.\d+))/mo =~ @request_line
        @request_method = $1
        @unparsed_uri   = $2
        @http_version   = HTTPVersion.new($3 ? $3 : "0.9")
      else
        rl = @request_line.sub(/\x0d?\x0a\z/o, '')
        raise HTTPStatus::BadRequest, "XXX bad Request-Line `#{rl}'."
      end
    end

	def _read_data(io, method, *arg)
		puts "in read_data"
      begin
        WEBrick::Utils.timeout(@config[:RequestTimeout]){
			puts "method: #{method}"
			begin
				return io.__send__(method, *arg)
			rescue Errno::EAGAIN => e
				puts e
				return nil
			end
        }
      rescue Errno::ECONNRESET
        return nil
      rescue TimeoutError
        raise HTTPStatus::RequestTimeout
      end
    end
  end
end

hello_proc = lambda do |req, resp|
  resp['Content-Type'] = "text/html"
  appDelegate = NSApplication.sharedApplication.delegate()
  text = appDelegate.sampleText()
    resp.body = %{
    <html><body>
    #{text}
    Hello. You're calling from a #{req['User-Agent']}
    <p>
    I see parameters: #{req.query.keys.join(', ')}
    </body></html>
  }
end

bye_proc = lambda do |req, resp|
  resp['Content-Type'] = "text/html"
  resp.body = %{
    <html><body>
    <h3>Goodbye!</h3>
    </body></html>
  }
end

hello = HTTPServlet::ProcHandler.new(hello_proc)
bye   = HTTPServlet::ProcHandler.new(bye_proc)

s = HTTPServer.new(:Port => 2000)
s.mount("/hello", hello)
s.mount("/bye", bye)
trap("INT"){s.shutdown}
puts ("starting")

# Thread.new do
s.start
# end
