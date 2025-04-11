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
 * Task 1+2: Plan for reacting to the addition of the goal !start
 * Triggering event: addition of goal !start
 * Context: the agents believes that a WoT TD of a was:Lights is located at Url
 * Body: creates an MQTTArtifact using makeArtifact, focuses on it, 
*/
@start_plan
+!start : td("https://was-course.interactions.ics.unisg.ch/wake-up-ontology#Lights", Url) <-
    .print("Hello world");
    // Create MQTTArtifact for communication with unique clientId "lights_controller"
    makeArtifact("mqttArtifactLights", "room.MQTTArtifact", ["lights_controller"], Art);
    focus(Art);
    +mqtt_artifact(Art);
    .print("MQTT artifact created and focused:", Art);
    // Create the ThingArtifact representing the lights using its TD
    makeArtifact("lights", "org.hyperagents.jacamo.artifacts.wot.ThingArtifact", [Url], LightsArt);
    .print("Lights Thing Artifact created:", LightsArt).

/* 
 * Task 1: Plan for reacting to a received messaage
 * Triggering event: a received message with performative "tell")
 * Context: the agent is focused on the MQTTArtifac
 * Body: prints the received message
*/
@react_received_msg_plan
+mqttMessage(Sender, tell, Content)
   <- .print("Lights Controller received MQTT message from ", Sender, " with content: ", Content).

/* 
 * Task 2: Plan for turning on the lights
 * Triggering event: addition of goal !turn_on_lights
 * Context: true (the plan is always applicable)
 * Body: 
 *   - Invokes the action affordance was:SetState based on the jacamo-hypermedia lib
 *   - Updates the internal belief 
 *   - Prints a confirmation message
 */
@turn_on_lights_plan
+!turn_on_lights : true <-
    invokeAction("https://was-course.interactions.ics.unisg.ch/wake-up-ontology#SetState", 
            ["https://www.w3.org/2019/wot/json-schema#StringSchema"], 
            ["on"])[artifact_id(LightsArt)];
    -+lights("off");
    +lights("on");
    .print("Lights turned on");
    .send(personal_assistant, tell, lights(on)).



/* 
 * Task 2: Plan for turning off the lights
 * Triggering event: addition of goal !turn_off_lights
 * Context: true (the plan is always applicable)
 * Body: 
 *   - Invokes the action affordance was:SetState based on the jacamo-hypermedia lib
 *   - Updates the internal belief 
 *   - Prints a confirmation message
 */
@turn_off_lights_plan
+!turn_off_lights : true <-
    invokeAction("https://was-course.interactions.ics.unisg.ch/wake-up-ontology#SetState", 
            ["https://www.w3.org/2019/wot/json-schema#StringSchema"], 
            ["off"])[artifact_id(LightsArt)];
    -+lights("on");
    +lights("off");
    .print("Lights turned off");
    .send(personal_assistant, tell, lights(off)).


/* Import behavior of agents that work in CArtAgO environments */
{ include("$jacamoJar/templates/common-cartago.asl") }