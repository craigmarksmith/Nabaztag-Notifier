require 'nabaztag/message'
require 'nabaztag/response'
require 'nabaztag/choreography'

#
# Nabaztag allows control of the text-to-speech, ear control, and choreography features of
# Nabaztag devices.
#
# To use this library, you need to know the MAC of the device (written on the base) and its
# API token. The token must be obtained from http://www.nabaztag.com/vl/FR/api_prefs.jsp .
#
# The API allows different commands to be dispatched simultaneously; in order to achieve this,
# this library queues commands until they are sent.
#
# E.g.
#   nabaztag = Nabaztag.new(mac, token)
#   nabaztag.say('bonjour')   # Nothing sent yet
#   nabaztag.move_ears(4, 4)  # Still not sent
#   nabaztag.send             # Messages sent
#
# This also means that if two conflicting commands are issued without an intervening send,
# only the latter will be carried out.
#
# However, beware! The API doesn't seem to respond well if multiple commands are sent in
# a short period of time: it can become confused and send erroneous commands to the device.
#
# In addition, the choreography command does not seem to play well with other commands: if
# text-to-speech and choreography are sent in one request, only the speech will get through
# to the rabbit.
#
# With version 2 of the API, it is now possible to specify a voice for the message. The
# default is determined by the rabbit's language (claire22s for French; heather22k for
# English). The voice's language overrides that of the rabbit: i.e. a French rabbit will
# speak in English when told to use an English voice.
#
# The known voices are grouped by language in the Nabaztag::VOICES constant, but no attempt
# is made to validate against this list, as Violet may introduce additional voices in future.
#
class Nabaztag

  class ServiceError < RuntimeError ; end

  attr_reader :mac, :token, :message
  attr_accessor :voice

  #
  # Create a new Nabaztag instance to communicate with the device with the given MAC address and
  # service token (see class overview for explanation of token).
  #
  def initialize(mac, token)
    @mac, @token = mac, token
    @message = new_message
    @ear_positions = [nil, nil]
  end
  
  #
  # Send all pending messages
  #
  def send
    @message.voice = voice
    response = @message.send
    @message = new_message
    unless response.success?
      raise ServiceError, response.raw
    end
    return response
  end

  #
  # Send a message immediately to get the ear positions.
  #
  def ear_positions
    ear_message = new_message
    ear_message.ears = 'ok'
    response = ear_message.send
    return [response.left_ear, response.right_ear]
  end

  #
  # Say text.
  #
  def say(text)
    message.tts = text
    nil
  end

  #
  # Say text immediately.
  #
  def say!(text)
    say(text)
    send
  end

  #
  # Make the rabbit bark.
  #
  def bark
    say('ouah ouah')
    nil
  end

  #
  # Bark immediately.
  #
  def bark!
    bark
    send
  end

  #
  # Set the position of the left and right ears between 0 and 16. Use nil to avoid moving an ear.
  # Note that these positions are not given in degrees, and that it is not possible to specify the
  # direction of movement. For more precise ear control, use choreography instead.
  #
  def move_ears(left, right)
    message.posleft = left if left
    message.posright = right if right
    nil
  end

  #
  # Move ears immediately.
  #
  def move_ears!(left, right)
    move_ears(left, right)
    send
  end

  #
  # Creates a new choreography message based on the actions instructed in the block. The commands
  # are evaluated in the context of a new Choreography instance.
  #
  # E.g.
  #  nabaztag.choreography do
  #    together { led :middle, :green ; led :left, :red }
  #    led :right, :yellow
  #    together { led :left, :off ; led :right, :off}
  #    ...
  #  end
  #
  def choreography(title=nil, &blk)
    message.chortitle = title
    message.chor = Choreography.new(&blk).build
    nil
  end

  #
  # Creates choreography and sends it immediately.
  #
  def choreography!(title=nil, &blk)
    choreography(title, &blk)
    send
  end

  def new_message
    return Message.new(mac, token)
  end

end
