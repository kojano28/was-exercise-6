// blinds controller agent

/* Initial beliefs */

// The agent has a belief about the location of the W3C Web of Thing (WoT) Thing Description (TD)
// that describes a Thing of type https://was-course.interactions.ics.unisg.ch/wake-up-ontology#Blinds (was:Blinds)
td("https://was-course.interactions.ics.unisg.ch/wake-up-ontology#Blinds", "https://raw.githubusercontent.com/Interactions-HSG/example-tds/was/tds/blinds.ttl").

// the agent initially believes that the blinds are "lowered"
blinds("lowered").

/* Initial goals */ 

// The agent has the goal to start
!start.

/* 
 * Task 1: Plan for reacting to the addition of the goal !start
 * Triggering event: addition of goal !start
 * Context: the agents believes that a WoT TD of a was:Blinds is located at Url
 * Body: creates an MQTTArtifact using makeArtifact, focuses on it, 
*/
@start_plan
+!start : td("https://was-course.interactions.ics.unisg.ch/wake-up-ontology#Blinds", Url) <-
    .print("Starting Blinds Controller...");
    makeArtifact("mqttArtifactBlinds", "room.MQTTArtifact", ["blinds_controller"], Art);
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
   <- .print("Blinds Controller received MQTT message from", Sender, "with content:", Content).

/* Import behavior of agents that work in CArtAgO environments */
{ include("$jacamoJar/templates/common-cartago.asl") }