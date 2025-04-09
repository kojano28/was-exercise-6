package room;

import cartago.Artifact;
import cartago.INTERNAL_OPERATION;
import cartago.OPERATION;
import org.eclipse.paho.client.mqttv3.*;

/**
 * A CArtAgO artifact that provides an operation for sending messages to agents 
 * with KQML performatives using the MQTT broker
 */
public class MQTTArtifact extends Artifact {

    MqttClient client;
    String broker = "tcp://test.mosquitto.org:1883";
    String clientId;
    String topic = "was-exercise-6/communication-jano";
    int qos = 2;

    public void init(String name) {
        try {
            clientId = name;
            client = new MqttClient(broker, clientId);
            MqttConnectOptions options = new MqttConnectOptions();
            options.setCleanSession(true);
            client.connect(options);
            client.setCallback(new MQTTCallback());
            client.subscribe(topic, qos);
            defineObsProperty("connected", true);
            System.out.println("Created MQTTClient: " + clientId + " to topic: " + topic);
            
        } catch (MqttException e) {
            e.printStackTrace();
        }
    }

    @OPERATION
    public void sendMsg(String agent, String performative, String content) {
        try {
            // Format message according to required syntax: agent,performative,content
            String messagePayload = agent + "," + performative + "," + content;
            
            MqttMessage message = new MqttMessage(messagePayload.getBytes());
            message.setQos(qos);
            
            // Publish message
            client.publish(topic, message);
            
        } catch (MqttException e) {
            e.printStackTrace();;
        }
    }

    @INTERNAL_OPERATION
    public void addMessage(String agent, String performative, String content) {
        // Create an observable property for the received message
        if (hasObsProperty("mqttMessage")) {
            // Update existing property if it exists
            updateObsProperty("mqttMessage", agent, performative, content);
        } else {
            // Create new property if it doesn't exist
            defineObsProperty("mqttMessage", agent, performative, content);
            System.out.println("Observable property created: " + agent + "," + performative + "," + content);
        }
    }

    // Custom callback class to process received messages
    private class MQTTCallback implements MqttCallback {

        @Override
        public void connectionLost(Throwable cause) {
            System.out.println("Connection to MQTT broker lost: " + cause.getMessage());
            updateObsProperty("connected", false);
        }

        @Override
        public void messageArrived(String topic, MqttMessage message) throws Exception {
            // Extract and parse
            String payload = new String(message.getPayload());
            System.out.println("Received message on topic: " + topic + ". Payload: " + payload);
            String[] parts = payload.split(",", 3);
            
            // Ensure message follows expected format and process it
            if (parts.length == 3 && parts[1].trim().equals("tell")) {
                System.out.println("Processing valid 'tell' message.");
                addMessage(parts[0].trim(), parts[1].trim(), parts[2].trim());
            }
        }

        @Override
        public void deliveryComplete(IMqttDeliveryToken token) {
            // Method left empty as requested
        }
    }
}