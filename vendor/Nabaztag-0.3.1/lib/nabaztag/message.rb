require 'cgi'
require 'iconv'
require 'open-uri'
require 'nabaztag/response'

class Nabaztag
  class Message

    SERVICE_ENCODING = 'iso-8859-1'
    API_URI = 'http://api.nabaztag.com/vl/FR/api.jsp?'
    FIELDS = [
      :idmessage, :posright, :posleft, :idapp, :tts, :chor, :chortitle, :ears, :nabcast, 
      :ttlive, :voice, :speed, :pitch, :action
    ]
    ACTIONS = {
      :preview         =>  1,
      :friend_list     =>  2,
      :list_messages   =>  3,
      :get_timezone    =>  4,
      :get_signature   =>  5,
      :get_blacklist   =>  6,
      :get_sleep_state =>  7,
      :get_version     =>  8,
      :get_voices      =>  9,
      :get_name        => 10,
      :get_languages   => 11,
      :preview_message => 12,
      :sleep           => 13,
      :wake            => 14
    }

    FIELDS.each do |field|
      attr_accessor field
    end

    def initialize(mac, token)
      @mac, @token = mac, token
      @expected_identifiers = []
    end
    
    def send
      puts request_uri
      Response.new(open(request_uri){ |io| io.read })
    end
    
    def expect(identifier)
      @expected_identifiers << identifier
    end
    
    def action=(name)
      @action = ACTIONS[name] or raise "unknown action #{name}"
    end

  private

    def request_uri
      API_URI + parameters.sort_by{ |k,v| k.to_s }.map{ |k,v|
        value = CGI.escape(v.to_s)
        "#{k}=#{value}"
      }.join('&')
    end
    
    def parameters
      FIELDS.inject({
        :sn => @mac,
        :token => @token
      }){ |hash, element|
        value = __send__(element)
        hash[element] = value if value
        hash
      }
    end

  end
end
