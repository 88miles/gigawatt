require 'trollop'
require 'highline/import'
require 'oauth2'
require 'fileutils'
require 'json'
require 'open-uri'
require 'terminal-table'
require 'launchy'

require File.join(File.dirname(__FILE__), 'gigawatt', 'cache')
require File.join(File.dirname(__FILE__), 'gigawatt', 'settings')
require File.join(File.dirname(__FILE__), 'gigawatt', 'project_file')
require File.join(File.dirname(__FILE__), 'gigawatt', 'application')
require File.join(File.dirname(__FILE__), 'gigawatt', 'oauth')
require File.join(File.dirname(__FILE__), 'gigawatt', 'options')
require File.join(File.dirname(__FILE__), 'gigawatt', 'commands', 'setup')
require File.join(File.dirname(__FILE__), 'gigawatt', 'commands', 'init')
require File.join(File.dirname(__FILE__), 'gigawatt', 'commands', 'start')
require File.join(File.dirname(__FILE__), 'gigawatt', 'commands', 'stop')
require File.join(File.dirname(__FILE__), 'gigawatt', 'commands', 'sync')
require File.join(File.dirname(__FILE__), 'gigawatt', 'commands', 'status')
require File.join(File.dirname(__FILE__), 'gigawatt', 'commands', 'log')

module Gigawatt
  CONNECTION_ERROR_EXIT_CODE = 4
  NO_PROJECT_EXIT_CODE = 3
  SETTINGS_FILE_EXISTS = 2
  INVALID_OAUTH_TOKEN_EXIT_CODE = 1
  OK_EXIT_CODE = 0
end
