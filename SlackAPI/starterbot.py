import os
import time
import re
import slack
from chatbot_engine import ChatbotEngine


# instantiate Slack client
slack_token = 'xoxb-698097631536-698102023152-pfqBYB9xGArAlO15orhjxExw'
rtmclient = slack.RTMClient(token=slack_token)
# starterbot's user ID in Slack: value is assigned after the bot starts up
starterbot_id = None

# constants
RTM_READ_DELAY = 1  # 1 second delay between reading from RTM
MENTION_REGEX = "^<@(|[WU].+?)>(.*)"

RESPONSE = ChatbotEngine()


def parse_bot_commands(slack_events):
    """
    Parses a list of events coming from the Slack RTM API to find bot commands.
    If a bot command is found, this function returns a tuple of command and
    channel.
    If its not found, then this function returns None, None.
    """
    for event in slack_events:
        if event["type"] == "message" and "subtype" not in event:
            user_id, message = parse_direct_mention(event["text"])
            if user_id == starterbot_id:
                return message, event["channel"]
    return None, None


def parse_direct_mention(message_text):
    """
    Finds a direct mention (a mention that is at the beginning) in message text
    and returns the user ID which was mentioned. If there is no direct mention,
    returns None
    """
    matches = re.search(MENTION_REGEX, message_text)
    # the first group contains the username,
    # the second group contains the remaining message
    return (matches.group(1),
            matches.group(2).strip()) if matches else (None, None)


def handle_command(command, channel):
    """
    Executes bot command if the command is known
    """
    # Default response is help text for the user
    # default_response =\
    #     "Not sure what you mean. Try *{}*.".format(EXAMPLE_COMMAND)

    # Finds and executes the given command, filling in response
    # response = None
    # This is where you start to implement more commands!
    # if command.startswith(EXAMPLE_COMMAND):
    #     response = "Sure...write some more code then I can do that!"
    response = RESPONSE.response(command)

    # Sends the response back to the channel
    slack_token.api_call(
        "chat.postMessage",
        channel=channel,
        # text=response or default_response
        text=response
    )


@slack.RTMClient.run_on(event='message')
def response(**kwargs):
    print("Starter Bot connected and running!")
    # Read bot's user ID by calling Web API method `auth.test`
    starterbot_id = slack_token.api_call("auth.test")["user_id"]
    while True:
        command, channel = parse_bot_commands(slack_token.rtm_read())
        if command:
            handle_command(command, channel)
        time.sleep(RTM_READ_DELAY)


if __name__ == "__main__":
    # if slack_token.rtm_connect(with_team_state=False):
    #     print("Starter Bot connected and running!")
    #     # Read bot's user ID by calling Web API method `auth.test`
    #     starterbot_id = slack_token.api_call("auth.test")["user_id"]
    #     while True:
    #         command, channel = parse_bot_commands(slack_token.rtm_read())
    #         if command:
    #             handle_command(command, channel)
    #         time.sleep(RTM_READ_DELAY)
    # else:
    #     print("Connection failed. Exception traceback printed above.")
    rtmclient.start()


# https://github.com/slackapi/python-slackclient/wiki/Migrating-to-2.x
# https://app.slack.com/client/TLJ2VJKFS/CL6LN0T1Q
# https://www.fullstackpython.com/blog/build-first-slack-bot-python.html
# https://chatbotsmagazine.com/contextual-chat-bots-with-tensorflow-4391749d0077?gi=71fda28a39d9
