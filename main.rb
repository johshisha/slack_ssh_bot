require 'slack'
require 'pry'
require 'dotenv'
require 'pty'
require 'expect'

require 'pry'

Dotenv.load

TOKEN = ENV["TOKEN"]
Slack.configure do | conf |
  conf.token = TOKEN
end

client = Slack.realtime

$expect_verbose = true
$cmd_result = ""
$output, input, pid = PTY.spawn('bash')

def run_shell
  while true do
    ret = $output.readline
    $cmd_result << ret
  end
end

Thread.new { run_shell }

client.on :message do |data|
  if not data['username'] == 'ssh_bot' then
    cmd = data['text'].gsub('&amp;', '&')
    p cmd
    input.puts cmd
    if cmd.gsub(/[\n|\r]/, "") == 'exit' then
      exit 0
    end
    sleep 1
    ret = $cmd_result.slice($cmd_result.index("$"), $cmd_result.size)
    $cmd_result = ""
    # p "#{ret}"
    Slack.chat_postMessage(text: "```#{ret}```", channel: 'ssh')
  end
end

# slackに接続できたときの処理
client.on :hello do
 puts 'connected!'
 Slack.chat_postMessage(text: "ssh_bot connected!", channel: 'ssh')
end


client.start
