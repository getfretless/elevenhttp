#!/usr/bin/env ruby
require 'cgi'
require 'erb'
require_relative 'my_app'

cgi = CGI.new
puts cgi.header

app = MyApp.new
app.layout do
  if cgi['page'] != ''
    app.render_view(cgi['page'])
  else
    app.render_view('index')
  end
end
