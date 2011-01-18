module Boticus
  class StateError < StandardError; end
end

require 'colored'
require 'zippy'
require 'aws/s3'

require 'boticus/bot'
