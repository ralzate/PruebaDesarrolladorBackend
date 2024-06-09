#!/usr/bin/env ruby

require File.expand_path('../../main', __FILE__)
include Games

[
  { text: 'sinatra', hint: 'Classy web-development dressed in a DSL' },
  { text: 'mongoid', hint: 'The officially supported ODM (Object-Document-Mapper) framework for MongoDB in Ruby' },
  { text: 'ruby', hint: 'A dynamic, open source programming language with a focus on simplicity and productivity' },
].each do |e|
  Games::Hangman.create(word: Games::Word.create(c: e[:text], h: e[:hint]))
end

