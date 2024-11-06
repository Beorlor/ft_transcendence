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
    if (json.type === "friend_connected") {
      let friend = document.getElementById(json.friend);
      if (friend) {
        friend.classList.add("online");
        friend.classList.remove("offline");
      }
    }
    if (json.type === "friend_disconnected") {
      let friend = document.getElementById(json.friend);
      if (friend) {
        friend.classList.add("offline");
        friend.classList.remove("online");
      }
    }
    if (json.type === "friend_request") {
      let pop_up = document.getElementById("pop-up");
      if (pop_up) {
        pop_up.innerHTML = `<div class="alert alert-info" role="alert">
            You have received a new friend request.
          </div>`;
      }
    }
  };

  connection.onclose = () => {
    console.log("Connexion fermée");
  };

  connection.onerror = (error) => {
    console.error("Erreur WebSocket :", error);
  };

  window.friendSocketConnection = connection;
}

window.addEventListener("DOMContentLoaded", (_) => {
  connexionFriendSocket();
});

window.connexionFriendSocket = connexionFriendSocket;
