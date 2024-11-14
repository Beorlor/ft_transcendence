const WINDOW_EVENTS = {};

window.WINDOW_ANIMATIONS_FRAMES = [];
window.CUSTOM_AUDIO_CONTEXT = new AudioContext();
window.CUSTOM_RENDERER = null;
window.CUSTOM_SCENE = null;
window.CUSTOM_LEVEL = null;
window.GAME_STATES = {
  default: 0,
  pong: 1,
  aipong: 2,
  threejs: 3,
};

window.GAMESTATE = -1;

window.addListener = (event, handler) => {
  if (!(event in WINDOW_EVENTS)) WINDOW_EVENTS[event] = [];
  WINDOW_EVENTS[event] = handler;
  window.addEventListener(event, handler);
};

window.removeAllListeners = (event) => {
  if (!(event in WINDOW_EVENTS)) return;
  for (let handler of WINDOW_EVENTS[event])
    window.removeEventListener(event, handler);
  history.pushState();
  delete WINDOW_EVENTS[event];
};

window.cancelAnimations = () => {
  for (let v in WINDOW_ANIMATIONS_FRAMES) window.cancelAnimationFrame(v);
  WINDOW_ANIMATIONS_FRAMES.length = 0;
  if (window.threeJSStop) {
	window.threeJSStop();
  }
};

window.resetHomePage = function () {
  const popUp = document.getElementById("pop-up");
  popUp.innerHTML = "";
  window.GAMESTATE = window.GAME_STATES.default;
  window.cancelAnimations();
  const game = document.getElementById("game");
  game.innerHTML = "";
};

window.popUpFonc = function showPopup(message) {
  const popupContainer = document.getElementById("pop-up");

  const popup = document.createElement("div");
  popup.className = "alert alert-info fade show";
  popup.style.animation = "slideIn 0.5s ease-out";
  popup.innerHTML = message;

  popupContainer.appendChild(popup);

  setTimeout(() => {
    popup.classList.add("fade");
    popup.remove();
  }, 6000);
};

function loadPageScript(game) {
  const script = game.querySelector("script");
  if (!script) return;
  const existingScripts = game.querySelectorAll('script[type="module"]');
  existingScripts.forEach((s) => s.remove());

  const newScript = document.createElement("script");
  newScript.type = "module";
  newScript.src = script.src;
  game.appendChild(newScript);

  newScript.onload = () => {
    if (document.getElementById("form_login")) {
      window.loadLoginFormAction();
    }
    if (document.getElementById("form_register")) {
      window.loadRegisterFormAction();
    }
    if (document.getElementById("form_validate_code")) {
      window.loadValidateForm();
    }
    if (document.getElementById("form_edit_profile")) {
      window.loadEditProfileFormAction();
    }
    if (window.location == "https://localhost/pong") {
      window.pongMain();
      window.GAMESTATE = window.GAME_STATES.pong;
    }
	if (window.location === "https://localhost/3dgame") {
		window.threeJSMain();
		window.GAMESTATE = window.GAME_STATES.threejs;
	}
	else {
		if (window.threeJSStop) {
			window.threeJSStop();
		}
	}
    if (
      window.location == "https://localhost/pongserv" ||
      window.location == "https://localhost/pongserv-ranked"
    ) {
      window.startNormalGame();
    }
  };
}

function rebindEvents() {
  removeAllListeners("click");
  document
    .getElementById("home_link")
    .addEventListener("click", handleHomeClick);
  document
    .getElementById("pong_link")
    .addEventListener("click", handlePongClick);
  if (document.getElementById("button_login")) {
    document
      .getElementById("button_login")
      .addEventListener("click", handleLoginClick);
    document
      .getElementById("button_register")
      .addEventListener("click", handleRegisterClick);
  } else if (document.getElementById("button_logout")) {
    document
      .getElementById("ranking_link")
      .addEventListener("click", handleRankingClick);
    document
      .getElementById("button_logout")
      .addEventListener("click", handleLogoutClick);
    document
      .getElementById("button_profile")
      .addEventListener("click", handleProfileClick);
    document
      .getElementById("add_friend_button")
      .addEventListener("click", handleAddFriendClick);
    document
      .getElementById("submit_friend_request")
      .addEventListener("click", handleSubmitFriendRequest);
    if (document.getElementById("edit_profile_button")) {
      document
        .getElementById("edit_profile_button")
        .addEventListener("click", handleEditProfileClick);
    }
    document.querySelectorAll(".accept-request").forEach((button) => {
      button.addEventListener("click", () => {
        const friendshipId = button.getAttribute("data-friendship-id");
        handleFriendRequestAction(friendshipId, "accepted", button);
      });
    });
    document.querySelectorAll(".reject-request").forEach((button) => {
      button.addEventListener("click", () => {
        const friendshipId = button.getAttribute("data-friendship-id");
        handleFriendRequestAction(friendshipId, "rejected", button);
      });
    });
  }
  if (document.getElementById("play_button")) {
    document
      .getElementById("play_button")
      .addEventListener("click", handlePlayEventClick);
  }
  if (document.getElementById("ranked_button")) {
    document
      .getElementById("ranked_button")
      .addEventListener("click", handleRankedEventClick);
  }
}

function loadPage(game, url, gamestate) {
  history.pushState(null, null, url);
  window.GAMESTATE = gamestate;
  let popUp = document.getElementById("pop-up");
  popUp.innerHTML = "";
  fetch(url, {
    headers: {
      "X-Requested-With": "XMLHttpRequest",
      IsLogged: document.getElementById("button_logout") ? true : false,
    },
  })
    .then((res) => res.json())
    .then((json) => {
      game.innerHTML = json.body;
      if (json.nav) {
        document.getElementById("nav").innerHTML = json.nav;
      }
      rebindEvents();
      loadPageScript(game);
    })
    .catch((err) => console.error("Error: ", err));
}

function handleHomeClick(ev) {
  ev.preventDefault();
  const url = "https://localhost";
  loadPage(document.getElementById("game"), url, window.GAME_STATES.default);
}

function handlePongClick(ev) {
  ev.preventDefault();
  const url = "https://localhost/pong";
  loadPage(document.getElementById("game"), url, window.GAME_STATES.pong);
}

function handleLoginClick(ev) {
  ev.preventDefault();
  const url = "https://localhost/login";
  loadPage(document.getElementById("game"), url, window.GAME_STATES.default);
}

function handleRegisterClick(ev) {
  ev.preventDefault();
  const url = "https://localhost/register";
  loadPage(document.getElementById("game"), url, window.GAME_STATES.default);
}

function handleRankingClick(ev) {
  ev.preventDefault();
  const url = "https://localhost/ranking";
  loadPage(document.getElementById("game"), url, window.GAME_STATES.default);
}

function handleLogoutClick(ev) {
  ev.preventDefault();
  fetch("https://localhost/api/auth/logout")
    .then((res) => res.json())
    .then((json) => {
      if (json.success) {
        if (
          window.friendSocketConnection &&
          window.friendSocketConnection.readyState === 1
        ) {
          window.friendSocketConnection.close();
        }
        const url = "https://localhost";
        loadPage(
          document.getElementById("game"),
          url,
          window.GAME_STATES.default
        );
      }
    })
    .catch((err) => console.error("Error: ", err));
}

function handleProfileClick(ev) {
  ev.preventDefault();
  const url = "https://localhost/profile";
  loadPage(document.getElementById("game"), url, window.GAME_STATES.default);
}

function handleEditProfileClick(ev) {
  ev.preventDefault();
  const url = "https://localhost/edit-profile";
  loadPage(document.getElementById("game"), url, window.GAME_STATES.default);
}

function handlePlayEventClick(ev) {
  ev.preventDefault();
  const url = "https://localhost/pongserv";
  loadPage(document.getElementById("game"), url, window.GAME_STATES.default);
}

function handleRankedEventClick(ev) {
  ev.preventDefault();
  const url = "https://localhost/pongserv-ranked";
  loadPage(document.getElementById("game"), url, window.GAME_STATES.default);
}

function handleAddFriendClick(ev) {
  ev.preventDefault();
  const modal = new bootstrap.Modal(document.getElementById("addFriendModal"));
  modal.show();
}

function handleSubmitFriendRequest(ev) {
  ev.preventDefault();
  const username = document.getElementById("friend_username").value;
  fetch("https://localhost/api/add-friend", {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
    },
    body: JSON.stringify({ friend_id: username }),
  })
    .then((res) => res.json())
    .then((json) => {
      if (json.success) {
        const modal = bootstrap.Modal.getInstance(
          document.getElementById("addFriendModal")
        );
        modal.hide();
        window.addFriendRequest(json.friend_name, json.friendship_id, true);
        document.getElementById("friend_username").value = "";
        if (
          window.friendSocketConnection &&
          window.friendSocketConnection.readyState === 1
        ) {
          window.friendSocketConnection.send(
            JSON.stringify({
              type: "add_friend",
              friend_id: json.friend_id,
              friendship_id: json.friendship_id,
            })
          );
        }
      } else {
        window.popUpFonc(json.error);
      }
    })
    .catch((err) => console.error("Error: ", err));
}

function handleFriendRequestAction(friendshipId, action, button) {
  fetch(`https://localhost/api/friend/${friendshipId}`, {
    method: "PATCH",
    headers: {
      "Content-Type": "application/json",
    },
    body: JSON.stringify({ status: action }),
  })
    .then((response) => response.json())
    .then((data) => {
      if (data.success) {
        const parentLi = button.closest("li");
        let username = parentLi.querySelector(".username").textContent;
        parentLi.remove();
        if (action === "accepted") {
          window.addFriendAccepted(username, data.friend_id, friendshipId);
          if (
            window.friendSocketConnection &&
            window.friendSocketConnection.readyState === 1
          ) {
            window.friendSocketConnection.send(
              JSON.stringify({
                type: "new_friend",
                friend_id: data.friend_id,
                status: "accepted",
                friendship_id: friendshipId,
              })
            );
          }
        } else {
          if (
            window.friendSocketConnection &&
            window.friendSocketConnection.readyState === 1
          ) {
            window.friendSocketConnection.send(
              JSON.stringify({
                type: "new_friend",
                friend_id: data.friend_id,
                status: "rejected",
                friendship_id: friendshipId,
              })
            );
          }
        }
        rebindEvents();
      } else {
        window.popUpFonc(data.error);
      }
    })
    .catch((error) => console.error("Fetch error:", error));
}

window.addEventListener("popstate", function (_) {
  const currentUrl = window.location.pathname;

  if (currentUrl !== window.location.pathname) {
    fetch(currentUrl, {
      headers: {
        "X-Requested-With": "XMLHttpRequest",
        IsLogged: document.getElementById("button_logout") ? true : false,
      },
    })
      .then((response) => response.text())
      .then((html) => {
        document.getElementById("game").innerHTML = html;
      })
      .catch((err) => console.error("Error during popstate fetch: ", err));
  }
});

document.addEventListener("DOMContentLoaded", (ev) => {
  rebindEvents();
});
