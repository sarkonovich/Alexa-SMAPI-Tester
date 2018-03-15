# SMAPITester
It's not going to change your life, but it will give you a convenient way to test your Alexa skill using the Alexa Skill Management API and Ruby.
SMAPITester provides some enhanced fuctionality over the ASK CLI to test your skills. It makes it much easier to load up a bunch of sample utterances and automate skill testing, providing a variety of different formats for outputting results.

Note: This is not a complete implementation of SMAPI. (It doesn't help you deploy or clone skills, for example.) It implements the skill testing operations, [as described here](https://developer.amazon.com/docs/smapi/skill-testing-operations.html). 

## Installation
Even though SMAPITester doesn't require ASK CLI and interacts with SMAPI directly, it's probably not a bad idea to set up ASK CLI. [Instructions here](https://developer.amazon.com/alexa-skills-kit/smapi)

You'll also need set up a Login With Amazon client to get the client id and client secret you'll need to access SMAPI. Instructions for doing that are [here.](https://developer.amazon.com/docs/smapi/ask-cli-intro.html#smapi-intro)


Download the SMAPITester repo. Start an IRB (or Pry, or your favorite...) session in the directory with the downloaded files, then require:

````require './smapi_tester'````
## Usage ##
### AlexaSimulator ###

Create an instance of the AlexaSimulator class, passing it two required parameters:
- skill id
- test phrases (Collect a bunch! Put them in an array!)


Create a new simulator instance:

````simulator = AlexaSimulator.new("my-skill-id", ["Open Magic Eight Ball", "Will I be rich"])````







================================================================
================================================================





