require 'rubygems'
require 'bundler/setup'

require 'jabber/bot'
require 'json'
require 'rest_client'

module Rubot
  def self.config
    YAML.load_file(File.expand_path('../config/rubot.yml', File.dirname(__FILE__)))[:rubot]
  end
  def self.run
    bot = Jabber::Bot.new(config)

    # Give your bot a private command, 'rand'
    bot.add_command(
      :syntax      => 'rand',
      :description => 'Produce a random number from 1 to 11',
      :regex       => /^rand$/,
      :is_public   => true
    ) do
      (rand(10)+1).to_s
    end

    # Give your bot a public command, 'puts <string>' with an alias 'p <string>'
    bot.add_command(
      :syntax      => 'puts <string>',
      :description => 'Write something to $stdout',
      :regex       => /^puts\s+(.+)$/,
      :alias       => [ :syntax => 'p <string>', :regex => /^p\s+(.+)$/ ],
      :is_public   => true
    ) do |sender, message|
      puts "#{sender} says '#{message}'"
      "'#{message}' written to $stdout"
    end

    bot.add_command(
      :syntax => 'environments',
      :description => 'list environments',
      :regex => /^environments/,
      :is_public => true
    ) do
      response = RestClient.get 'http://localhost:3000/environments.json'
      body = JSON.parse(response.body)
      message = ''
      body.each do |e|
        if e['reserved_by'].strip == ''
          message += "#{e['name']} is not reserved\n"
        else
          message += "#{e['name']} was reserved by #{e['reserved_by']} at #{e['updated_at']}\n"
        end
      end
      message
    end

    bot.add_command(
      :syntax => "who's on <environment>",
      :description => "find out who's using an environment",
      :regex => /^who's on\s+(.+)$/,
      :is_public => true
    ) do |sender, message|
      index_response = RestClient.get 'http://localhost:3000/environments.json'
      environments_index = JSON.parse(index_response.body)
      environment = environments_index.select{|env| env['name'] == message}.first
      message = ''
      if environment['reserved_by'].strip == ''
          message += "#{environment['name']} is not reserved\n"
      else
          message += "#{environment['reserved_by']} is on #{environment['name']} since #{environment['updated_at']}\n"
      end
      message
    end

    bot.connect
  end
end
