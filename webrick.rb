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

hello_proc = lambda do |req, resp|
  resp['Content-Type'] = "text/html"
  resp.body = %{
    <html><body>
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
