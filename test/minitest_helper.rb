$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'webmock'
include WebMock::API

require 'staccato/rack'

require 'minitest/reporters'
MiniTest::Reporters.use!
require 'minitest/autorun'
