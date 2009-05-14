class Nabaztag

  #
  # The Choreography class uses class methods to implement a simple DSL. These build API choreography
  # messages based on instructions to move the ears and light the LEDs.
  #
  class Choreography

    LED_COLORS = {
      :red          => [255,   0,   0],
      :orange       => [255, 127,   0],
      :yellow       => [255, 255,   0],
      :green        => [  0, 255,   0],
      :blue         => [  0,   0, 255],
      :purple       => [255,   0, 255],
      :dim_red      => [127,   0,   0],
      :dim_orange   => [127,  63,   0],
      :dim_yellow   => [127, 127,   0],
      :dim_green    => [  0, 127,   0],
      :dim_blue     => [  0,   0, 127],
      :dim_purple   => [127,   0, 127],
      :off          => [  0,   0,   0]
    }
    EARS = {:left => [1], :right => [0], :both => [0,1]}
    LEDS = {:bottom => 0, :left => 1, :middle => 2, :right => 3, :top => 4}
    EAR_DIRECTIONS = {:forward => 0, :backward => 1}
    
    def initialize(&blk)
      @messages = []
      @tempo = 10
      @time_stamp = 0
      instance_eval(&blk) if block_given?
    end

    def build
      return (['%d' % @tempo] + @messages).join(',')
    end

    #
    # Set the tempo of the choreography in Hz (i.e. events per secod). The default is 10
    # events per second.
    #
    def tempo(t)
      @tempo = t
    end

    #
    # Move :left, :right, or :both ears to angle degrees (0-180) in direction
    # :forward (default) or :backward.
    #
    def ear(which_ear, angle, direction=:forward)
      direction_number = EAR_DIRECTIONS[direction]
      EARS[which_ear].each do |ear_number|
        append_message('motor', ear_number, angle, 0, direction_number)
      end
      advance
    end

    #
    # Change colour of an led (:top, :right:, middle, :left, :bottom) to a specified colour.
    # The colour may be specified either as RGB values (0-255) or by using one of the named colours
    # in LED_COLORS.
    #
    # E.g.
    #  led :middle, :red
    #  led :top, 0, 0, 255
    #  led :bottom, :off
    #
    def led(which_led, c1, c2=nil, c3=nil)
      led_number = LEDS[which_led]
      if (c1 && c2 && c3)
        red, green, blue = c1, c2, c3
      else
        red, green, blue = LED_COLORS[c1]
      end
      append_message('led', led_number, red, green, blue)
      advance
    end

    #
    # Group several actions into a single chronological step via a block.
    #
    # E.g.
    #  event { led :top, :yellow ; ear :both, 0 }
    #
    def event(duration=1, &blk)
      length(duration, &blk)
    end
    
    alias_method :together, :event

    #
    # Perform one or more actions for n chronological steps
    #
    # E.g.
    #  length 3 do
    #    led :top, :red ; led :middle, :yellow
    #  end
    #
    def length(duration, &blk)
      old_in_event = @in_event
      @in_event = true
      yield
      @in_event = old_in_event
      advance duration
    end

  private

    def append_message(*params)
      @messages << ("%d,%s,%d,%d,%d,%d" % ([@time_stamp] + params))
    end

    def advance(duration=1)
      @time_stamp += duration unless @in_event
    end

  end
end
