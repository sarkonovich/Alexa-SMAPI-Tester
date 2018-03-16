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


Optionally, you can enter a 'locale' parameter. By default, it's "en-US"

````simulator = AlexaSimulator.new("my-skill-id", "en-CA", ["Open Magic Eight Ball", "Will I be rich"])````


SMAPITester needs OAuth2 tokens to interact with SMAPI. The first time you run AlexaSimulator a browser window should open. Supply your Login With Amazon client id and client secret to retrieve access and refresh tokens. AlexaSimulator will automatically handle refreshing access tokens for you.

#### NOTE: SMAPITester stores the following information in hidden files in the /lib/smapi_tester directory: ####


.alexa_tester_tokens.json # access and refresh tokens

.client_credential # LWA client id and client secret

If for some reason you need to get new tokens (e.g., you've changed your client), you can run:

````simulator.init````


##### #run_simulations #####

First, you need to run the simulations for the skill, phrases and locales.

````simulator.run_simulations````

Which will yield some output like this:
````ruby
"d151d269-5ac7-4169-bb0c-2e99638d7d33"
"42a6c9a8-acf6-4cea-a966-5ef322e7d909"
=======================================================
Completed 2 / 2 request(s)
=======================================================
=> {"open magic eight ball"=>"d151d269-5ac7-4169-bb0c-2e99638d7d33", "will I be rich"=>"42a6c9a8-acf6-4cea-a966-5ef322e7d909"}
````

Note that the session remains open as you iterate through the phrases, unless you invoke an intent that closes it. So, you can test a multi-turn interaction by supplying an array of phrases like:

````ruby
  [
    "open my travel skill", 
    "to Portland, Oregon", 
    "next Wednesday", 
    "non-stop"
  ]
 ````

##### #get_simulation_results #####

The above method will return (and store as an instance variable) a hash containing the simulation id(s). To retrieve the results of the simulations you last ran

````simulator.get_simulation_results````
````ruby
================================================================
Retrieved 2 / 2 simulation result(s)
Successes: 2 / Failures: 0
================================================================
=> [{"d151d269-5ac7-4169-bb0c-2e99638d7d33"=>[{"result_status"=>"SUCCESSFUL"}, {"invocation_phrase"=>"open magic eight ball"}]},
 {"42a6c9a8-acf6-4cea-a966-5ef322e7d909"=>[{"result_status"=>"SUCCESSFUL"}, {"invocation_phrase"=>"will I be rich"}]}
 ````
 By default, this method returns only whether the simulation was SUCCESSFUL or a FAILURE.
 However, it can take several output options:
 
 
 - request    # returns the request JSON
 - response   # returns the Alexa response JSON
 - result     # returns the entire JSON response
 
For example,

````simulator.get_simulation_results(output: "response")````
````ruby
[{"d151d269-5ac7-4169-bb0c-2e99638d7d33"=>
   {"response"=>
     {"body"=>
       {"version"=>"1.0",
        "response"=>
         {"outputSpeech"=>{"type"=>"PlainText", "text"=>"I'm ready to tell your future. Ask me any yes no question."},
          "directives"=>[],
          "reprompt"=>{"outputSpeech"=>{"type"=>"PlainText"}},
          "shouldEndSession"=>false},
        "sessionAttributes"=>{}}}}},
 {"42a6c9a8-acf6-4cea-a966-5ef322e7d909"=>
   {"response"=>
     {"body"=>
       {"version"=>"1.0",
        "response"=>
         {"outputSpeech"=>{"type"=>"PlainText", "text"=>"the future is uncertain"},
          "directives"=>[],
          "reprompt"=>{"outputSpeech"=>{"type"=>"PlainText"}},
          "shouldEndSession"=>false},
        "sessionAttributes"=>{}}}}}]
````

You can write the results to a file:

````simulator.get_simulation_results(output: "response", write: true)````

 ##### #test

 The #test method just wraps #run_simulations and #get_simulation_results together

 ````simulator.test````
 
 You can pass in test phrases as a named parameter:

 ````simulator.test(phrases: ["open magic eight ball", "will I marry"])````
 
 ````ruby
"e9ed4562-f192-42ec-b8a1-351980776d4c"
"65b6cc95-49c0-4639-815f-29f2406a8426"
=======================================================
Completed 2 / 2 request(s)
=======================================================
================================================================
Retrieved 2 / 2 simulation result(s)
Successes: 2 / Failures: 0
================================================================
=> [{"e9ed4562-f192-42ec-b8a1-351980776d4c"=>[{"result_status"=>"SUCCESSFUL"}, {"invocation_phrase"=>"open magic eight ball"}]},
 {"65b6cc95-49c0-4639-815f-29f2406a8426"=>[{"result_status"=>"SUCCESSFUL"}, {"invocation_phrase"=>"will I marry"}]}]
 ````

#### Errors ####
It's *not* uncommon for the tests to throw the following error:
````
Skill Simulation Error: Call simulate-skill error.
Error code: 409
{
  "message": "This simulation request conflicts with another one currently being processed."
}
````
SMAPI seems to be pretty picky about how quickly you can send requests. If you send requests too quickly, you get this error. By default, AlexaTester leaves a 3 second pause between requests. If that isn't slow enough, you get the 409 error. AlexaTester will resend the request three times.


Also, it takes a bit of time for the Amazon to process the simulation requests. ````#get_simulation_results```` will retry if the results aren't ready:
````ruby
=======================================================
AlexaTesterError::SimulationInProgress: 200 
retrying...
================================================================
````

### AlexaInvoker ###


SMAPI also allow you to [invoke your skill](https://developer.amazon.com/docs/smapi/skill-invocation-api.html) with a request JSON (as opposed to just an invocation phrase). This would let you, for example, invoke your skill as if it were in the middle of a multi-turn session, with session attributes set, etc. 


````invoker = AlexaInvoker.new````

Use the JSON generated by the get_simulation_results method

````json = simulator.get_simulation_results(output: "request")````

````invoker.invoke(json)````
