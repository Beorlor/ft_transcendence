const url = "wss://localhost/pongsocket/pong";
const connection = new WebSocket(url);

connection.onopen = () => {
  console.log("Connecté au serveur WebSocket");
  connection.send("Hello from the client!");
};

connection.onmessage = (event) => {
  console.log("Message reçu :", event.data);
};

connection.onclose = () => {
  console.log("Connexion fermée");
};

connection.onerror = (error) => {
  console.error("Erreur WebSocket :", error);
};
