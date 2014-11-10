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