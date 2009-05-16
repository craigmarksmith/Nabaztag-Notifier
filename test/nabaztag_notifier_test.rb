require File.dirname(__FILE__) + '/test_helper'

class NabaztagNotifierTest < Test::Unit::TestCase

  def setup
    @nabaztag_stub = stub_everything('nabaztag', :use_voice => nil)
    Nabaztag.stubs(:new).returns(@nabaztag_stub)
    @notifier = NabaztagNotifier.new
    # stub the logging
    logger = stub('logger', :debug => nil)
    @notifier.stubs(:logger).returns(logger)

    @notifier.stubs(:fixed_announcements).returns([
      "Hooray! $PERSON$ has fixed the $PROJECT$ build."
    ])
    @notifier.stubs(:breakage_announcements).returns([
      "Oh dear! Build for $PROJECT$ was broken by $PERSON$."
    ])
  end

  def test_should_lower_nabaztag_ears_on_broken_build
    @notifier.stubs(:announcement)
    @nabaztag_stub.stubs(:say)
    @nabaztag_stub.expects(:move_ears).with(10, 10)
    @nabaztag_stub.expects(:send)
    @notifier.build_broken('test', 'test')
  end

  def test_should_announce_breakage_on_broken_build
    @nabaztag_stub.stubs(:move_ears)
    @nabaztag_stub.expects(:say).with("Oh dear! Build for Reevoo was broken by Tom.")
    @nabaztag_stub.expects(:send)
    source_control = stub_everything('git', :latest_revision => stub_everything(:author => "tomlea"))
    project = stub_everything("reevoo", :source_control => source_control, :name => 'Reevoo')
    @build_stub = stub('build', :project => project)
    @notifier.build_broken(@build_stub, 'test')
  end

  def test_should_raise_nabaztag_ears_on_fixed_build
    @notifier.stubs(:announcement)
    @nabaztag_stub.stubs(:say)
    @nabaztag_stub.expects(:move_ears).with(1, 1)
    @nabaztag_stub.expects(:send)
    @notifier.build_fixed('test', 'test')
  end

  def test_should_announce_fixed_build
    @nabaztag_stub.stubs(:move_ears)
    @nabaztag_stub.expects(:say).with("Hooray! James Mead has fixed the Reevoo build.")
    @nabaztag_stub.expects(:send)
    
    source_control = stub_everything('git', :latest_revision => stub_everything(:author => "James Mead"))
    project = stub_everything("reevoo", :source_control => source_control, :name => 'Reevoo')
    @build_stub = stub('build', :project => project)
    
    @notifier.build_fixed(@build_stub, 'test')
  end

  def test_should_announce_a_fixed_build_when_there_is_no_available_changeset
    @nabaztag_stub.stubs(:move_ears)
    @nabaztag_stub.expects(:say).with("Hooray! Ya Mum has fixed the Reevoo build.")
    @nabaztag_stub.expects(:send)
    
    source_control = stub_everything('git', :latest_revision => nil)
    project = stub_everything("reevoo", :source_control => source_control, :name => 'Reevoo')
    @build_stub = stub('build', :project => project)
    NullChangeset.any_instance.stubs(:author).returns('Ya Mum')
    
    @notifier.build_fixed(@build_stub, 'test')
  end
  
end
