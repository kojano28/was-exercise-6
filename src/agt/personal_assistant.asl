// personal assistant agent

broadcast(jason).

/* Task 4: Initial beluefs */ 


// ranking Lights
prefer(naturalLight, 0).
prefer(artificialLight, 1).


// mapping controllers to wake up methos
wakeupMethod(blinds, naturalLight).
wakeupMethod(lights, artificialLight).

/* Initial goals */ 

// The agent has the goal to start
!start.


/* 
 * Task 1:Plan for reacting to the addition of the goal !start
 * Triggering event: addition of goal !start
 * Context: true (the plan is always applicable)
 * Body: greets the user
*/
@start_plan
+!start : true <-
    .print("Hello world");
    makeArtifact("mqttArtifactPersonal", "room.MQTTArtifact", ["personal_assistant"], Art);
    focus(Art);
    +mqtt_artifact(Art);
    .print("MQTT artifact created and focused:", Art).

/* 
 * Task 1: Plan for sending MQTT messages (using the artifact directly).
 * Triggering event: addition of goal !send_mqtt(Sender, Performative, Content)
 * Context: true (the agent is free to send MQTT messages whenever needed)
 * Body: calls the artifact operation 'sendMsg' passing the three parameters.
 */
@send_mqtt_plan
+!send_mqtt(Sender, Perf, Content)
  <- ?mqtt_artifact(Art);
     sendMsg(Sender, Perf, Content)[artifact_id(Art)];
     .print("MQTT message from ", Sender, " with performative ", Perf, " using ", Art).

/* 
 * Task 1: Plan for broadcasting a message using Jasons  broadcast mechanism or MQTT.
 * Triggering event: addition of goal !selective_broadcast
 * Context: the agent can broadcast whenever needed
 * Body: broadcasts a 'tell' message with the given Info to all agents in the MAS.
 */
@selective_broadcast_plan
+!selective_broadcast(Agent, Performative, Content) : broadcast(jason) <-
    .broadcast(tell, message(Agent, Performative, Content));
    .print("Broadcasting via Jason: ", Content).

+!selective_broadcast(Sender, Performative, Content) : broadcast(mqtt) <-
    !send_mqtt(Sender, Performative, Content). 

/* 
 * Task 1: Plan for reacting to a received messaage
 * Triggering event: a received message with performative "tell")
 * Context: the agent is focused on the MQTTArtifact
 * Body: prints the received message
*/
@react_received_mqtt_msg_plan
+mqttMessage(Sender, tell, Content)
  <- .print("Personal Assistant Received MQTT message from", Sender, "with content:", Content).


/* 
 * Task 3: Plan for reacting to a received message, like states from the controllers, except their proposals
*/
@react_message_plan
+message(Agent, tell, Content) : true <-
    .print("Personal Assistant received Jason message from ", Agent, ": ", Content).

// Task 4.3

// Wake up routine if event "now" and owner "asleep" 
@wake_up_routine_plan
+!wake_up_routine : true <-
    .print("Wake-up Routine: Broadcasting CFP for wake up");
    !selective_broadcast(personal_assistant, tell, cfp(wake_up, increase_illuminance));
    .print("Broadcast/CFP sent.");
    .wait(7000);
    if (proposalReceived(_)) {
        .print("Proposals received; proceeding with accepted actions.");
    } else {
        !noProposals;
    }.

// Task 4: additional plan to check the owners state and start wake_up_routine again
@wakeup_loop_plan
+!wakeup_loop : owner_state("asleep") <-
    .print("User is still asleep. Initiating a new wake-up round...");
    !wake_up_routine;
    .wait(10000);
    -proposalReceived(true);
    !wakeup_loop.

// proposal from blinds
@proposal_from_blinds_plan
+propose(blinds, raise) : owner_state("asleep") & wakeupMethod(blinds, naturalLight) <-
    .print("Personal Assistant: Received proposal from Blinds Controller. Accepting proposal.");
    .send(blinds_controller, tell, accept(blinds, raise));
    +proposalReceived(true);
    .print("Confirmation of proposal sent.").

// prooposal from lights
@proposal_from_lights_plan
+propose(lights, on) : owner_state("asleep") & wakeupMethod(lights, artificialLight) <-
    .print("Personal Assistant: Received proposal from Lights Controller. Accepting proposal.");
    .send(lights_controller, tell, accept(lights, on));
    +proposalReceived(true).

/* 
 * Task 4.1: Plan for reacting to the addition of the belief that there is an upcoming event "now".
 * Triggering event: addition of belief upcoming_event("now")
 * Context: 
 *   - If owner_state("awake") then print "Enjoy your event"
 *   - If owner_state("asleep") then print "Starting wake-up routine"
 */
@upcoming_event_awake_plan
+upcoming_event("now") : owner_state("awake") <-
    .print("Enjoy your event").

@upcoming_event_asleep_plan
+upcoming_event("now") : owner_state("asleep") <-
    .print("Starting wake-up routine");
    .wait(7000); //info: wait for the process, because of the artifact creation
    !wakeup_loop.

// Task 4.4

@no_proposals_delegation_plan
+!noProposals : true <-
    .print("No proposals received");
    .print("Delegating wake-up to a friend via MQTT...");
    !send_mqtt("friend_agent", tell, "cfp(wake_up(owner))");
    .print("Delegation message sent to friend_agent").


/* Import behavior of agents that work in CArtAgO environments */
{ include("$jacamoJar/templates/common-cartago.asl") }