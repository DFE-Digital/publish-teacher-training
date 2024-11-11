# frozen_string_literal: true

require 'webrick'

WEBrick::HTTPRequest.const_set('MAX_URI_LENGTH', 2083 * 2)
