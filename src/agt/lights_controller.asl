// lights controller agent

/* Initial beliefs */

// The agent has a belief about the location of the W3C Web of Thing (WoT) Thing Description (TD)
// that describes a Thing of type https://was-course.interactions.ics.unisg.ch/wake-up-ontology#Lights (was:Lights)
td("https://was-course.interactions.ics.unisg.ch/wake-up-ontology#Lights", "https://raw.githubusercontent.com/Interactions-HSG/example-tds/was/tds/lights.ttl").

// The agent initially believes that the lights are "off"
lights("off").

/* Initial goals */ 

// The agent has the goal to start
!start.

/* 
 * Task 1: Plan for reacting to the addition of the goal !start
 * Triggering event: addition of goal !start
 * Context: the agents believes that a WoT TD of a was:Lights is located at Url
 * Body: creates an MQTTArtifact using makeArtifact, focuses on it, 
*/
@start_plan
+!start : td("https://was-course.interactions.ics.unisg.ch/wake-up-ontology#Lights", Url) <-
    .print("Starting Lights Controller...");
    makeArtifact("mqttArtifactLights", "room.MQTTArtifact", ["lights_controller"], Art);
    focus(Art);
    +mqtt_artifact(Art);
    .print("MQTT artifact created and focused:", Art).


/* 
 * Task 1: Plan for reacting to a received messaage
 * Triggering event: a received message with performative "tell")
 * Context: the agent is focused on the MQTTArtifac
 * Body: prints the received message
*/
@react_received_msg_plan
+mqttMessage(Sender, tell, Content)
   <- .print("Lights Controller received MQTT message from ", Sender, " with content: ", Content).

/* Import behavior of agents that work in CArtAgO environments */
{ include("$jacamoJar/templates/common-cartago.asl") }