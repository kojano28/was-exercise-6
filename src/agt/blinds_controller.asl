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
 * Task 1+2: Plan for reacting to the addition of the goal !start
 * Triggering event: addition of goal !start
 * Context: the agents believes that a WoT TD of a was:Blinds is located at Url
 * Body: creates an MQTTArtifact using makeArtifact, focuses on it, creates ThingArtifact for the blinds
*/
@start_plan
+!start : td("https://was-course.interactions.ics.unisg.ch/wake-up-ontology#Blinds", Url) <-
    .print("Hello world");
    // Create MQTTArtifact for communication.
    makeArtifact("mqttArtifactBlinds", "room.MQTTArtifact", ["blinds_controller"], Art);
    focus(Art);
    +mqtt_artifact(Art);
    .print("MQTT artifact created and focused:", Art);
    // Create the ThingArtifact representing the blinds using its WoT TD.
    makeArtifact("blinds", "org.hyperagents.jacamo.artifacts.wot.ThingArtifact", [Url], BlindsArt);
    .print("Blinds Thing Artifact created:", BlindsArt).
/* 
 * Task 1: Plan for reacting to a received messaage
 * Triggering event: a received message with performative "tell")
 * Context: the agent is focused on the MQTTArtifac
 * Body: prints the received message
*/
@react_received_msg_plan
+mqttMessage(Sender, tell, Content)
   <- .print("Blinds Controller received MQTT message from", Sender, "with content:", Content).


/* 
 * Task 2: Plan for raising the blinds
 * Triggering event: addition of the goal !raise_blinds
 * Context: true (the plan is always applicable)
 * Body: 
 *   - Exploits the action affordance was:SetState based on the jacamo-hypermedia lib
 *   - Updates the internal belief
 *   - Prints a confirmation
 */
@raise_blinds_plan
+!raise_blinds : true <-
    invokeAction("https://was-course.interactions.ics.unisg.ch/wake-up-ontology#SetState",["raised"]);
    -blinds("lowered");
    +blinds("raised");
    .print("Blinds raised");
    .send(personal_assistant, tell, blinds("raised")). // Task 3


/* 
 * Task 2: Plan for lowering the blinds
 * Triggering event: addition of the goal !lower_blinds
 * Context: true (the plan is always applicable)
 * Body: 
 *   - Exploits the action affordance was:SetState based on the jacamo-hypermedia lib
 *   - Updates the internal belief
 *   - Prints a confirmation
 */
@lower_blinds_plan
+!lower_blinds : true <-
    invokeAction("https://was-course.interactions.ics.unisg.ch/wake-up-ontology#SetState",["lowered"]);
    -blinds("raised");
    +blinds("lowered");
    .print("Blinds lowered");
    .send(personal_assistant, tell, blinds("lowered")). // Task 3

// Task 4.3

// If the blinds are lowered, the blinds controller should propose to raise the blinds
@cfp_blinds_lowered_plan
+message(personal_assistant, tell, cfp(wake_up, increase_illuminance)) : blinds("lowered") <-
    .print("Blinds Controller: Blinds are lowered. Proposing to raise blinds.");
    .send(personal_assistant, tell, propose(blinds, raise)).

// if the blindes are already raised then it should refuse the call
@cfp_blinds_raised_plan
+message(personal_assistant, tell, cfp(wake_up, increase_illuminance)) : blinds("raised") <-
    .print("Blinds Controller: Blinds are already raised. Refusing CFP.");
    .send(personal_assistant, tell, refuse(blinds, raise)).

// accepted proposal received
@accept_blinds_plan
+accept(blinds, raise) : true <-
    .print("Blinds Controller: Acceptance received. Raising blinds.");
    !raise_blinds.


/* Import behavior of agents that work in CArtAgO environments */
{ include("$jacamoJar/templates/common-cartago.asl") }