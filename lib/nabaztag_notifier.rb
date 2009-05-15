require File.join(File.dirname(__FILE__), *%w[wiki_quotes])

USER_ALIASES = {
  'lukeredpath' => "Luke",
  'paulbattley' => "Paul",
  'chrisroos' => "Chris",
  'bensales' => "Ben",
  'louisg' => "Loo-wee",
  'jamesadam' => "James Adam",
  'adamjames' => "Adam",
  'jamesmead' => "James Mead",
  'alexmaccaw' => "Alex",
  'craigsmith' => "Craig",
  'tomlea' => "Tom"
}

PROJECT_ALIASES = {
  'reevoo' => 'reevoo dot com',
  'reevoomark' => 'reevoo mark',
  'revieworld' => 'review world',
  'revieworld-reevoomark' => 'review-world ree-voo-mark integration',
  'plugins' => 'plug-ins'
}

class NullChangeset
  def committed_by
    "Some scoundrel"
  end
end

class NabaztagNotifier
  NABAZTAG_MAC = '0013D3845142'
  NABAZTAG_TOKEN = '1189464819'
  NABAZTAG_VOICE = 'UK-Shirley'

  BREAKAGE_ANNOUNCEMENTS = [
    "Oh dear! $PROJECT$ build was broken by $PERSON$.",
    "Warning! Warning! $PROJECT$ build is broken! It was $PERSON$ what done it!",
    "Oh dear! Not again! $PROJECT$ build was broken by $PERSON$.",
    "$PERSON$ is a mentalist! He has broken the $PROJECT$ build!"
  ]

  FIXED_ANNOUNCEMENTS = [
    "$PERSON$ fixed the $PROJECT$ build. Normal service has resumed. #{WikiQuotes.random_quote}"
  ]

  def initialize(project = nil)
    @nabaztag = Nabaztag.new(NABAZTAG_MAC, NABAZTAG_TOKEN)
    @nabaztag.voice = NABAZTAG_VOICE
  end

  def logger
    CruiseControl::Log
  end

  def build_broken(broken_build, previous_build)
    logger.debug("Nabaztag notifier: sending 'build broken' message to Nabaztag")
    @nabaztag.say(announcement(broken_build, breakage_announcements))
    @nabaztag.move_ears(10, 10)
    @nabaztag.send
  end

  def build_fixed(fixed_build, previous_build)
    logger.debug("Growl notifier: sending 'build fixed' message to Nabaztag")
    @nabaztag.say(announcement(fixed_build, fixed_announcements))
    @nabaztag.move_ears(1, 1)
    @nabaztag.send
  end

  private
    def changeset_for_build(build)
      changeset_parser.parse_log(build.changeset.split("\n")).first || NullChangeset.new
    end

    def changeset_parser
      @changeset_parser ||= Subversion::ChangesetLogParser.new
    end

    def announcement(build, announcement_templates)
      changeset = changeset_for_build(build)
      project_name = project_name(build.project.name)
      person = user_name(changeset.committed_by)
      announcement_template = announcement_templates.random_value
      announcement_template.gsub!('$PERSON$', person)
      announcement_template.gsub!('$PROJECT$', project_name)
      announcement_template
    end

    def user_name(name)
      return USER_ALIASES[name] if USER_ALIASES.has_key?(name)
      return name
    end

    def project_name(project)
      return PROJECT_ALIASES[project] if PROJECT_ALIASES.has_key?(project)
      return project
    end

    def breakage_announcements
      BREAKAGE_ANNOUNCEMENTS
    end

    def fixed_announcements
      FIXED_ANNOUNCEMENTS
    end
end
