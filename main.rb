require 'slack'
require 'pry'
require 'dotenv'

Dotenv.load

TOKEN = ENV["TOKEN"]
Slack.configure do | conf |
  conf.token = TOKEN
end

client = Slack.realtime

client.on :message do |data|
  if not data['username'] == 'ssh_bot' then
    cmd = data['text'].gsub('&amp;', '&')
    p cmd
    ret = `#{cmd}`
    Slack.chat_postMessage(text: "```$ #{cmd}\n#{ret}```", channel: 'ssh')
  end
end

# slackに接続できたときの処理
client.on :hello do
 puts 'connected!'
 Slack.chat_postMessage(text: "ssh_bot connected!", channel: 'ssh')
end


client.start
