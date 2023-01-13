require "http/server"
require "./render-handler.cr"

module IconRendererServer
  extend self

  VERSION = "0.1.0"

  Log = ::Log.for("icon-renderer-server")

  def run()
    server = HTTP::Server.new([
      HTTP::LogHandler.new,
      HTTP::StaticFileHandler.new("public/", fallthrough: true, directory_listing: false),
      IconRendererServer::RenderHandler.new
    ])

    listen_on = URI.parse(ENV["LISTEN_ON"]? || "http://localhost:8080").normalize

    case listen_on.scheme
    when "http"
      server.bind_tcp(listen_on.hostname.not_nil!, listen_on.port.not_nil!)
    when "unix"
      server.bind_unix(listen_on.to_s.sub("unix://",""))
    end

    Log.info { "Listening on #{listen_on}" }
    server.listen
  end
end

IconRendererServer.run()
