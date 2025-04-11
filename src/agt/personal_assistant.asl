// personal assistant agent

broadcast(jason).

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
 * Triggering event: addition of goal !send_mqtt(Recipient, Performative, Content)
 * Context: true (the agent is free to send MQTT messages whenever needed)
 * Body: calls the artifact operation 'sendMsg' passing the three parameters.
 */
@send_mqtt_plan
+!send_mqtt(Recipient, Perf, Content)
  <- ?mqtt_artifact(Art);
     sendMsg(Recipient, Perf, Content)[artifact_id(Art)];
     .print("Personal Assistant Sent MQTT message to ", Recipient, " with performative ", Perf, " using ", Art).

/* 
 * Task 1: Plan for broadcasting a message using Jasons  broadcast mechanism or MQTT.
 * Triggering event: addition of goal !selective_broadcast
 * Context: the agent can broadcast whenever needed
 * Body: broadcasts a 'tell' message with the given Info to all agents in the MAS.
 */
@selective_broadcast_plan
+!selective_broadcast(Sender, Performative, Content) : broadcast(jason) <-
    .broadcast(tell, message(Sender, Performative, Content));
    .print("Broadcasting via Jason: ", Content).

+!selective_broadcast(Sender, Performative, Content) : broadcast(mqtt) <-
    !send_mqtt(Sender, Performative, Content). 

/* 
 * Task 1: Plan for reacting to a received messaage
 * Triggering event: a received message with performative "tell")
 * Context: the agent is focused on the MQTTArtifact
 * Body: prints the received message
*/
@react_received_msg_plan
+mqttMessage(Sender, tell, Content)
  <- .print("Personal Assistant Received MQTT message from", Sender, "with content:", Content).

/* Import behavior of agents that work in CArtAgO environments */
{ include("$jacamoJar/templates/common-cartago.asl") }