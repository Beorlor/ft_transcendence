function connexionFriendSocket() {
  const url = "wss://localhost/friendsocket/";
  const connection = new WebSocket(url);

  connection.onopen = () => {
    console.log("Connected to the friend socket.");
    connection.send("Hello from the client!");

    setInterval(() => {
      connection.send(
        JSON.stringify({
          type: "ping",
        })
      );
    }, 15000);
  };

  connection.onmessage = (event) => {
    let json = JSON.parse(event.data);
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
      window.addFriendRequest(json.username, json.friendship_id, false);
      let pop_up = document.getElementById("pop-up");
      if (pop_up) {
        window.popUpFonc("You have received a new friend request.");
      }
    }
  };

  connection.onclose = () => {
    console.log("Disconnected from the friend socket.");
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
