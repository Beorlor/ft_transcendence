function connexionFriendSocket() {
  const url = "wss://localhost/friendsocket/";
  const connection = new WebSocket(url);

  connection.onopen = () => {
    console.log("Connecté au serveur WebSocket friend");
    connection.send("Hello from the client!");
  };

  connection.onmessage = (event) => {
    console.log("data : ", event.data);
    let json = JSON.parse(event.data);
    console.log(json);
  };

  connection.onclose = () => {
    console.log("Connexion fermée");
  };

  connection.onerror = (error) => {
    console.error("Erreur WebSocket :", error);
  };
}

window.addEventListener("DOMContentLoaded", (_) => {
  connexionFriendSocket();
});

window.connexionFriendSocket = connexionFriendSocket;
