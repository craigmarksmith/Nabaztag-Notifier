$LOAD_PATH << File.join(File.dirname(__FILE__), 'vendor', 'nabaztag', 'lib')
$LOAD_PATH << File.join(File.dirname(__FILE__), 'lib')

require 'nabaztag'
require 'array_random_value'
require 'nabaztag_notifier'

Project.plugin :nabaztag_notifier
