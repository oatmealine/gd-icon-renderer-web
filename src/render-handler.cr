require "vips"
require "gd-icon-renderer"
require "mime"

module IconRendererServer
  ROBOT_ANIMATIONS = IconRenderer::Assets.load_animations("data/Robot_AnimDesc.plist")
  SPIDER_ANIMATIONS = IconRenderer::Assets.load_animations("data/Spider_AnimDesc.plist")

  class RenderHandler
    include HTTP::Handler

    # nabbed from https://github.com/watzon/cor/blob/master/src/cor/cor.cr#L33
    private def hex_to_rgb(hex : String)
      hex = hex.gsub(/^#/, "")

      # Raise if the hex string contains invalid characters
      if !(hex =~ /[a-fA-F0-9]+/)
        raise "hex string `#{hex}` contains invalid characters"
      end

      # Raise if the hexstring isn't of a valid length
      if !([3, 6, 8].includes?(hex.size))
        raise "hex string must be either 3, 6, or 8 characters long"
      end

      # Make the hex string the correct length
      if [3, 4].includes?(hex.size)
        hex = hex.split("").map(&.* 2).join
      end

      # Add alpha on there if it doesn't exist
      if hex.size == 6
        hex += "ff"
      end

      # Subdivide it up into rgb values
      components = hex.scan(/.{2}/)
      red, green, blue, alpha = components.map(&.[0].to_i(16))

      return [red/255, green/255, blue/255, alpha/255]
    end

    private def parse_color(color : String?) : Array(Float64)?
      if !color
        return nil
      end

      if color.to_i? && IconRenderer::Constants::COLORS[color.to_i]?
        IconRenderer::Constants::COLORS[color.to_i]
      else
        begin
          hex_to_rgb(color)
        rescue
          return nil
        end
      end
    end

    def call(context : HTTP::Server::Context)
      path = context.request.path
      query = context.request.query_params

      if path.starts_with?("/icon.")
        begin
          color1 = parse_color(query["color1"]?)
          color2 = parse_color(query["color2"]?)
          color3 = parse_color(query["color3"]?)

          icon_type = query["type"]? || "cube"
          icon_i = query["value"]?.try &.to_i? || 1

          gamemode = IconRenderer::Constants::GamemodeType.parse(icon_type)
          basename = IconRenderer::Renderer.get_basename(gamemode, icon_i)
          sheet = IconRenderer::Assets.load_spritesheet("data/icons/#{basename}-uhd.plist")

          icon_img = IconRenderer::Renderer.render_icon(
            gamemode, icon_i,
            color1 || IconRenderer::Constants::COLORS[0],
            color2 || IconRenderer::Constants::COLORS[3],
            color3,
            query["glow"]? ? true : false,
            sheet, ROBOT_ANIMATIONS, SPIDER_ANIMATIONS
          )

          alpha = icon_img.extract_band(3)
          left, top, width, height = alpha.find_trim(threshold: 1, background: [0])
          icon_img = icon_img.crop(left, top, width, height)

          begin
            context.response.content_type = MIME.from_filename(path)
          rescue
            context.response.content_type = "application/octet-stream"
          end
          icon_img.write_to_target(context.response, path)
        rescue err
          Log.error { "error while handling #{path}:" }
          Log.error { err.to_s }
          Log.error { err.backtrace }
          context.response.content_type = "text/html"
          context.response.respond_with_status(500, "Internal server error occurred, sorry about that")
        end
      else
        call_next(context)
      end
    end
  end
end
