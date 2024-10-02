// Mise à jour de l'URL du WebSocket
const url = "wss://localhost/pongsocket/pong";
const connection = new WebSocket(url);

// Gérer l'ouverture de la connexion
connection.onopen = () => {
  console.log("Connecté au serveur WebSocket");
  connection.send("Hello from the client!");
};

// Gérer les messages reçus
connection.onmessage = (event) => {
  console.log("Message reçu :", event.data);
};

// Gérer la fermeture de la connexion
connection.onclose = () => {
  console.log("Connexion fermée");
};

// Gérer les erreurs
connection.onerror = (error) => {
  console.error("Erreur WebSocket :", error);
};
