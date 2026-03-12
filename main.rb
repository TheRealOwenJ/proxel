#Proxel by TheRealOwenJ
require "gosu"

class ProxelWindow < Gosu::Window
  def initialize(file)
    abort "Error: File must be a .prxl file" unless file.downcase.end_with?(".prxl")

    @pixels = {}
    @frames = []
    @current_frame = 0
    @frame_time = 0
    @fps = 1
    @loop_video = false
    @canvas_type = "image"
    @pixel_size = 40

    parse(file)

    @width ||= 10
    @height ||= 10
    super(@width * @pixel_size, @height * @pixel_size)
    self.caption = "Proxel"

    if @canvas_type == "video" && @frames.any?
      @frames.compact!
      @pixels = @frames[0]
    end
  end

  def parse(file)
    current_frame_pixels = {}
    in_frame = false
    frame_number = nil

    File.readlines(file).each do |line|
      line = line.strip
      next if line.empty? || line.start_with?("#")
      parts = line.split

      if parts[0] == "init" && parts[1] == "canvas"
        @width = parts[2].to_i
        @height = parts[3].to_i
        default_color = color_from_name(parts[4])
        @pixel_size = parts[5].to_i
        @canvas_type = parts[7]

        if @canvas_type == "video"
          @fps = parts[8].to_i
          @loop_video = (parts[9] == "loop")
        end

        @width.times do |x|
          @height.times do |y|
            @pixels[[x, y]] = default_color
          end
        end
        next
      end

      if parts[0] == "frame" && parts[2] == "{"
        in_frame = true
        frame_number = parts[1].to_i
        current_frame_pixels = {}
        next
      end

      next if line == "}" && !in_frame

      if line == "}" && in_frame
        in_frame = false
        @frames[frame_number - 1] = current_frame_pixels
        frame_number = nil
        next
      end

      target = in_frame ? current_frame_pixels : @pixels
      parse_pixel_or_line(target, parts)
    end
  end

  def parse_pixel_or_line(pixels, parts)
    if parts[0] == "line"
      x1 = parts[1].to_i - 1
      y1 = parts[2].to_i - 1
      x2 = parts[3].to_i - 1
      y2 = parts[4].to_i - 1
      color = color_from_name(parts[5])
      draw_line_pixels(pixels, x1, y1, x2, y2, color)
    else
      x = parts[0].to_i - 1
      y = parts[1].to_i - 1
      pixels[[x, y]] = color_from_name(parts[2])
    end
  end

  def draw_line_pixels(pixels, x1, y1, x2, y2, color)
    dx = (x2 - x1).abs
    dy = (y2 - y1).abs
    sx = x1 < x2 ? 1 : -1
    sy = y1 < y2 ? 1 : -1
    err = dx - dy
    x = x1
    y = y1

    loop do
      pixels[[x, y]] = color
      break if x == x2 && y == y2
      e2 = err * 2
      if e2 > -dy
        err -= dy
        x += sx
      end
      if e2 < dx
        err += dx
        y += sy
      end
    end
  end

  def color_from_name(name)
    {
      "red" => Gosu::Color::RED,
      "green" => Gosu::Color::GREEN,
      "blue" => Gosu::Color::BLUE,
      "yellow" => Gosu::Color::YELLOW,
      "white" => Gosu::Color::WHITE,
      "black" => Gosu::Color::BLACK,
      "gray" => Gosu::Color::GRAY,
      "cyan" => Gosu::Color.argb(0xff00ffff),
      "magenta" => Gosu::Color.argb(0xffff00ff),
      "orange" => Gosu::Color.argb(0xffffa500),
      "purple" => Gosu::Color.argb(0xff800080),
      "brown" => Gosu::Color.argb(0xffa52a2a),
      "pink" => Gosu::Color.argb(0xffffc0cb),
      "lime" => Gosu::Color.argb(0xff00ff00)
    }[name.downcase] || Gosu::Color::FUCHSIA
  end

  def update
    return if @canvas_type == "image"

    @frame_time += 1
    return unless @frame_time >= 60 / @fps
    @frame_time = 0

    next_frame = @current_frame + 1
    if next_frame >= @frames.size
      if @loop_video
        @current_frame = 0
      else
        close
        return
      end
    else
      @current_frame = next_frame
    end

    @pixels = @frames[@current_frame]
  end

  def draw
    @pixels.each do |(x, y), color|
      Gosu.draw_rect(
        x * @pixel_size,
        y * @pixel_size,
        @pixel_size,
        @pixel_size,
        color
      )
    end
  end
end

abort "Usage: ruby main.rb <file.prxl>" if ARGV.empty?
ProxelWindow.new(ARGV[0]).show

