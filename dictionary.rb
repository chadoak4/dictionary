require 'rubygems'
require 'webrick'

class Displaydictionary < WEBrick::HTTPServlet::AbstractServlet
  def do_GET(request, response)

    if File.exist?("dictionary.txt")
      dictionary = File.readlines("dictionary.txt")
    else
      dictionary = []
    end


    response.status = 200
    response.body = %{
      <html>
      <head>
      <style>
      body {
        background-color: blue;}
        h1 {
          color: white;
          text-align: center;
          font-size: 50px;}
          </style>
          </head>
          <body>
          <header>
          <h1>Welcome to Iron Dictionary<h1>
          <h2><a href="/add">Add Words to Our Growing Dictionary!</a><h2>
          </header>
          <form method="POST" action="/search">
            <ul>
              <li>Search : <input name="input_search"/></li>
            </ul>
            <button type="submit">Submit!</button>
          </form>
           #{dictionary.join("<br/>")}
          </body>
          </html>
        }


      end
    end

class Add < WEBrick::HTTPServlet::AbstractServlet
  def do_GET(request, response)

    response.status = 200
    response.header["Location"] = "/save"
    response.body = %{
      <html>
        <head>
          <style>
            body {
            background-color: blue;}
            h1 {
            color: white;
            text-align: center;
            font-size: 50px;}
          </style>
        </head>
        <body>
          <header>
            <h1>Add to the Iron Dictionary<h1>
          </header>
            <form method="POST" action="/save">
              <ul>
                <li>What is the word you would like to add to the dictionary? <input name="word"/></li>
                <li>What is the definition of the word? <input name="definition"/</li>
              </ul>
              <button type="submit">Submit!</button>
            </form>
            </body>
          </html>}
  end
end

class Save < WEBrick::HTTPServlet::AbstractServlet
  def do_POST(request, response)
    File.open("dictionary.txt", "a+") do |file|
      file.puts "Word : #{request.query["word"]} : Definition :#{request.query["definition"]}"
    end


  response.status = 302
  response.header["Location"] = "/"
  response.body = ""
  end
end

class Search < WEBrick::HTTPServlet::AbstractServlet
  def do_POST(request, response)
    lines =File.readlines("dictionary.txt")
    match = lines.select do |line|
      line.include? (request.query["input_search"])
    end
  html_match = "<ul>" + (match.map {|line| "<li> #{line}</li>"}).join + "</ul>"


  response.status = 200
  response.body = %{
      <html>
          <head>
            <style>
              body {
              background-color: blue;}
              h1 {
              color: white;
              text-align: center;
              font-size: 50px;}
            </style>
          </head>
          <body>
            <header>
              <h1>Search Results<h1>
            </header>
            <h2><a href="/">Back to Dictionary!</a><h2>
            <p>
            #{html_match}
            </p>
              </body>
            </html>
          }
  end
end


    server = WEBrick::HTTPServer.new(:Port=>3000)
    server.mount "/", Displaydictionary
    server.mount "/add", Add
    server.mount "/save", Save
    server.mount "/search", Search


    trap("INT") {
      server.shutdown
    }

    server.start
