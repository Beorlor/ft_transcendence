const WINDOW_EVENTS = {};

window.WINDOW_ANIMATIONS_FRAMES = [];
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
};

window.resetHomePage = function () {
  const popUp = document.getElementById("pop-up");
  popUp.innerHTML = "";
  window.GAMESTATE = window.GAME_STATES.default;
  window.cancelAnimations();
  const game = document.getElementById("game");
  game.innerHTML = "";
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
    console.log(`Script ${script.src} loaded.`);

    if (document.getElementById("form_login")) {
      console.log(document.getElementById("form_login"));
      window.loadLoginFormAction();
    }
    if (document.getElementById("form_register")) {
      console.log(document.getElementById("form_register"));
      window.loadRegisterFormAction();
    }
    if (document.getElementById("form_validate_code")) {
      console.log(document.getElementById("form_validate_code"));
      window.loadValidateForm();
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
  }
}

function loadPage(game, url, gamestate) {
  console.log("loadPage: ", url);
  history.pushState(null, null, url);
  window.GAMESTATE = gamestate;
  fetch(url, {
    headers: {
      "X-Requested-With": "XMLHttpRequest",
      IsLogged: document.getElementById("button_logout") ? true : false,
    },
  })
    .then((res) => res.json())
    .then((json) => {
      console.log("body :", json.body);
      game.innerHTML = json.body;
      if (json.nav) {
        document.getElementById("nav").innerHTML = json.nav;
        rebindEvents();
      }
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
  const url = "https://localhost/profil";
  loadPage(document.getElementById("game"), url, window.GAME_STATES.default);
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
