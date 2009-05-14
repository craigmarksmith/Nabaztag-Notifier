require 'rexml/document'

class Nabaztag
  class Response
    include REXML

    ERROR_MESSAGES = /^NO|^ABUSE|NOTSENT$/

    attr_reader :raw

    def initialize(xml)
      @raw = xml
      @doc = Document.new(xml)
    end

    def messages
      lookup('/rsp/message')
    end

    def comments
      lookup('/rsp/comment')
    end

    def friends
      lookup('/rsp/friend@name')
    end

    def timezone
      lookup('/rsp/timezone').first
    end

    def rabbit_version
      lookup('/rsp/rabbitVersion').first
    end

    def rabbit_name
      lookup('/rsp/rabbitName').first
    end

    def voices
      XPath.match(@doc, '/rsp/voice').inject({}){ |h, n|
        lang    = n.attributes['lang']
        command = n.attributes['command']
        (h[lang] ||= []) << command
        h
      }
    end

    def languages
      lookup('/rsp/myLang@lang')
    end

    def left_ear
      position = lookup('/rsp/leftposition').first
      position && position.to_i
    end

    def right_ear
      position = lookup('/rsp/rightposition').first
      position && position.to_i
    end
    
    def signature
      lookup('/rsp/signature')
    end

    def success?
      !messages.any?{ |m| m =~ ERROR_MESSAGES }
    end

  private

    def lookup(xpath)
      XPath.match(@doc, xpath).map{ |n| n.text }
    end

  end
end
