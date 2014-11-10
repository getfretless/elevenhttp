### ElevenHTTP

Let's talk a little about how a web page is served

At its most basic form, it is a just a pipe of text that is being sent by the server, and interpreted by your web browser.

We built some ruby script files yesterday, but now let's turn it up a few notches.

Open a new file and name it `hello.cgi`. Did I just give anyone any bad flashbacks? Can someone here explain what CGI is?

CGI is what we did back in the bronze age of the internet. We had graduated from carving HTML into stone tablets, and started putting actual code in our webpages (code code, not mere markup, like html)....

CGI stands for Common Gateway Interface (is more info really necessary??)

Let's put the hashbang at the top and put this in (paste in Flowdock):

```ruby
#!/usr/bin/env ruby
puts "Content-type: text/html

<html>
  <head>
    <title>Cool Ruby</title>
  </head>
  <body>
    Hello, World!
  </body>
</html>"
```

Ruby has a simple built-in webserver that we can use to serve up some files, so let's tell it to run a server on port 5000 to serve this file.

    ruby -run -e httpd -- -p 5000 .

If you like, you can save this to a file:

    #!/bin/bash
    ruby -run -e httpd -- -p 5000 .'

and run it like this:
```
chmod +x rubyserve
./rubyserve
```

Open `localhost:5000` you'll see the contents of the directory you started the server in. Click on `hello.cgi`

*YAY!*

Files with an extension of `.cgi` and have that hashbang are special, and will be executed by many webservers (as long as they are configured to), so our `hello.cgi` was executed, and `puts`'d its string to your web browser. Your web browser saw that first line (with Content-Type), and decided, "Yeah, I can serve text/html"

The web browser knows that the headers end when there is a blank line, so that's why that is there. We can add extra headers there if we wanted to (like expires or cache-control headers).

Let's make it do something a little more interesting.
```ruby
#!/usr/bin/env ruby

greetings = ['Mr. President', 'Your Honor', 'Your Highness']
greeting = greetings.sample

puts "Content-type: text/html

<html>
  <head>
    <title>Cool Ruby</title>
  </head>
  <body>
    Hello, #{greeting}!
    <img src='under_construction.gif'>
  </body>
</html>"
```

Now, every time we load this page, a random greeting is shown.

How can we deal with user input (params and forms) though?

Let's use the Ruby `cgi` module just a little, mostly to get the params, but we also get this `#header` method, too:

(aside about what require does, look at [CGI](http://ruby-doc.org/stdlib-2.1.2/libdoc/cgi/rdoc/index.html), explain that it is a class that we can now instantiate, with methods that can be called on it)

```ruby
#!/usr/bin/env ruby
require 'cgi'
cgi = CGI.new

greetings = ['Mr. President', 'Your Honor', 'Your Highness']
if cgi['name'].empty?
  greeting = greetings.sample
else
  greeting = cgi['name']
end

puts cgi.header
puts "<html>
  <head>
    <title>Cool Ruby</title>
  </head>
  <body>
    Hello, #{greeting}!
    <img s rc='under_construction.gif'>
  </body>
</html>"
```

Now, If I put `?name=dave` at the end of my URL, I'll see a custom greeting just for me.

Okay, so what if we want to render a whole different page based on the URL?

Lets add some stuff to do that.

```ruby
#!/usr/bin/env ruby
require 'cgi'
cgi = CGI.new
puts cgi.header

if cgi['page'] == 'about'
  puts "<html>
    <head>
      <title>Cool Ruby</title>
    </head>
    <body>
      This is the about us page.
    </body>
  </html>"
else
  puts "<html>
    <head>
      <title>Cool Ruby</title>
    </head>
    <body>
      This is the home page.
    </body>
  </html>"
end
```

Man, this is cool, but we can't build all our web pages like this. If I were to build a bunch of pages, I'd have to repeat all this boilerplate html code all over again, and if something ever had to change, I'd have to change all this html code.

Let's extract that out into a resuable method.

```ruby
#!/usr/bin/env ruby
require 'cgi'
cgi = CGI.new

def header
  "<html><head><title>Cool Ruby</title></head><body>"
end

def footer
  "</body></html>"
end

puts cgi.header
puts header

if cgi['page'] == 'about'
  puts "This is the about us page."
else
  puts "This is the home page."
end

puts footer
```

This is better, but we can use that yield from yesterday to make things a little nicer:

```ruby
#!/usr/bin/env ruby
require 'cgi'
cgi = CGI.new

def layout(&block) # the block arg here is not necessary to declare
  puts "<html><head><title>Cool Ruby</title></head><body>"
  puts yield
  puts "</body></html>"
end

puts cgi.header

layout do
  if cgi['page'] == 'about'
    puts "This is the about us page."
  else
    puts "This is the home page."
  end
end
```

LAB: Make link_to
Extra credit: Make link_to work with args, or with a block.

Our pages are really more complicated than this, and we'd like to have them in thier own files, so lets break this up a bit.

Create a new file in the same directory, and name it `about.html` and paste in that content.
Create another file named `index.html` and use that content.
Back in `hello.cgi`, let's build a method to render out the file we want, and if it doesn't exist, render the index instead.

```ruby
#!/usr/bin/env ruby
require 'cgi'
cgi = CGI.new

def layout(&block)
  puts "<html><head><title>Cool Ruby</title></head><body>"
  puts yield
  puts "</body></html>"
end

def render_view(view_name)
  puts File.read("#{view_name}.html")
end

puts cgi.header

layout do
  if cgi['page'] == 'about'
    render_view('about')
  else
    render_view('index')
  end
end
```

That was cool, let's do that with the layout, too. Create a file and name it `layout.html.erb`, and modify the layout method like this:
```ruby
def layout(&block)
  raw_file = File.read('layout.html.erb')
  puts ERB.new(raw_file).result(binding)
end
```

And add this line to the top of the file:

    require 'erb'

And paste our html in the layout with a `yield` like so:
```ruby
<!DOCTYPE html>
<html>
  <head>
    <title>Cool Ruby</title>
  </head>
  <body>
    The time is now: <%= Time.now %>
    <br>
    <%= yield %>
  </body>
</html>
```

(let's talk about ERB and binding for a bit, how it is part of the Standard Lib, etc)

Let's convert the view templates to use ERB, too. Rename the `index.html` and `hello.html` files to `index.html.erb` and `about.html.erb`, and update `render_view` to use ERB.
```ruby
def render_view(view_name)
  raw_file = File.read("#{view_name}.html.erb")
  ERB.new(raw_file).result(binding)
end
```

Move methods into a new class, instantiate class and start calling methods on that class.
```ruby
#!/usr/bin/env ruby
require 'cgi'
require 'erb'

cgi = CGI.new

class MyApp

  def layout(&block)
    raw_file = File.read('layout.html.erb')
    puts ERB.new(raw_file).result(binding)
  end

  def render_view(view_name)
    raw_file = File.read("#{view_name}.html.erb")
    ERB.new(raw_file).result(binding)
  end

end

app = MyApp.new

puts cgi.header

app.layout do
  if cgi['page'] == 'about'
    app.render_view('about')
  else
    app.render_view('index')
  end
end
```

An inline class like this kind of works for testing an idea, but let's move this class into its own file named `my_app.rb`, require it, and use it like so:

Replace the `MyApp` class with:
```ruby
require_relative 'my_app'
app = MyApp.new
```

`require_relative` is new to Ruby 2, so in a lot of older code, you'll probably see this instead:

    require File.dirname(__FILE__) + '/my_app'

They are equivalent, though. `__FILE__` is a special Ruby variable that means the file path of the script currently being executed.

We can also move the stuff in this layout to a new file, too.

Lab: Make new method in `my_app.rb` and move either the layout block or the contents of the layout block to it.
Extra Credit: Move that stuff into a new class instead, and call it `routes.rb`
Extra Credit 2: Look up Ruby's File class and see how you can render a 404 page if the file in `cgi['page']` doesn't exist.

Final version (for now):

hello.cgi
```ruby
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
```

my_app.rb
```ruby
class MyApp

  def layout(&block)
    raw_file = File.read('layout.html.erb')
    puts ERB.new(raw_file).result(binding)
  end

  def render_view(view_name)
    file_name = "#{view_name}.html.erb"
    if File.exist?(file_name)
      raw_file = File.read(file_name)
      ERB.new(raw_file).result(binding)
    else
      render_404
    end
  end

  def render_404
    File.read('404.html')
  end

  def link_to(url, text='', &block)
    if block_given?
      "<a href='#{url}'>#{yield}</a>"
    else
      "<a href='#{url}'>#{text}</a>"
    end
  end

end
```

layout.html.erb
```ruby
<html>
  <head>
    <title>Cool Ruby</title>
  </head>
  <body>
    <%= yield %>
  </body>
</html>
```

index.html.erb
```ruby
This is the "Home" page<br>
<%= link_to('http://hotbot.com/', 'Hotbot') %>
```

about.html.erb
```ruby
This is the "About Us" page<br>
<%= 'HELLO ' * 5 %>
```

404.html
```html
<h1>404: page not found</h1>
```
