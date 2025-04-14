// calendar manager agent

/* Initial beliefs */

// The agent has a belief about the location of the W3C Web of Thing (WoT) Thing Description (TD)
// that describes a Thing of type https://was-course.interactions.ics.unisg.ch/wake-up-ontology#CalendarService (was:CalendarService)
td("https://was-course.interactions.ics.unisg.ch/wake-up-ontology#CalendarService", "https://raw.githubusercontent.com/Interactions-HSG/example-tds/was/tds/calendar-service.ttl").

// Task 2: initial belief -> no upcoming events
upcoming_event(_).

/* Initial goals */ 

// The agent has the goal to start
!start.

/* 
 * Task 2: Plan for reacting to the addition of the goal !start
 * Triggering event: addition of goal !start
 * Context: the agents believes that a WoT TD of a was:CalendarService is located at Url
 * Body: greets the user
*/
@start_plan
+!start : td("https://was-course.interactions.ics.unisg.ch/wake-up-ontology#CalendarService", Url) <-
    .print("Hello world");
    // performs an action that creates a new artifact of type ThingArtifact, named "calenderService" using the WoT TD located at Url
    // the action unifies ArtId with the ID of the artifact in the workspace
    makeArtifact("calenderService", "org.hyperagents.jacamo.artifacts.wot.ThingArtifact", [Url], CalenderArt);
    .print("Calender Service Thing Artifact created:", CalenderArt);
    !read_upcoming_event. // creates the goal !read_upcoming_event


/* 
 * Task 2: Plan for reading the upcoming event periodically.
 * Triggering event: addition of goal !read_upcoming_event
 * Context: true (the plan is always applicable)
 * Body: Exploits the TD Property Affordance was:ReadUpcomingEvent to read the upcoming event,
 *       updates its belief upcoming_event, prints the event, and waits 5000ms before repeating.
*/
@read_upcoming_event_plan
+!read_upcoming_event : true <-
    // performs an action that exploits the TD Property Affordance of type was:ReadUpcomingEvent 
    // the action unifies EventLst with a list holding the upcoming events, e.g. ["now"]
    readProperty("https://was-course.interactions.ics.unisg.ch/wake-up-ontology#ReadUpcomingEvent", EventLst);
    .nth(0, EventLst, Event); // performs an action that unifies Event with the element of the list EventLst at index 0
    -+upcoming_event(Event); // updates the beleif upcoming_event
    .print("Calendar Manager: Upcoming event: ", Event);
    .wait(5000);
    .send(personal_assistant, tell, upcoming_event(Event)); // Task 3
    !read_upcoming_event. // creates the goal !read_upcoming_event, for polling events


/* Import behavior of agents that work in CArtAgO environments */
{ include("$jacamoJar/templates/common-cartago.asl") }
