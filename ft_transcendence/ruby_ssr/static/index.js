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
	WINDOW_EVENTS[event].push(handler);
	window.addEventListener(event, handler);
};

window.removeAllListeners = (event) => {
	if (!(event in WINDOW_EVENTS)) return;
	for (let handler of WINDOW_EVENTS[event])
		window.removeEventListener(event, handler);
	delete WINDOW_EVENTS[event];
};

window.cancelAnimations = () => {
	for (let v of WINDOW_ANIMATIONS_FRAMES) window.cancelAnimationFrame(v);
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
	};
}

function rebindEvents() {
	console.log("Rebinding events...");
	document
		.getElementById("home_link")
		.addEventListener("click", handleHomeClick);
	document
		.getElementById("pong_link")
		.addEventListener("click", handlePongClick);
	document
		.getElementById("aipong_link")
		.addEventListener("click", handleAIPongClick);
	if (document.getElementById("button_login")) {
		document
			.getElementById("button_login")
			.addEventListener("click", handleLoginClick);
		document
			.getElementById("button_register")
			.addEventListener("click", handleRegisterClick);
	} else if (document.getElementById("button_logout")) {
		document
			.getElementById("button_logout")
			.addEventListener("click", handleLogoutClick);
		document
			.getElementById("button_profile")
			.addEventListener("click", handleProfileClick);
	}
}

function loadPage(game, url) {
	let isPong = url.includes("pong");
	history.pushState(null, null, url);
	window.GAMESTATE = isPong ? window.GAME_STATES.pong : window.GAME_STATES.default;
	console.log(window.GAMESTATE);
	fetch(url, {
		headers: {
			"X-Requested-With": "XMLHttpRequest",
			Authorization: localStorage.getItem("Authorization"),
			IsLogged: document.getElementById("button_logout") ? true : false,
		},
	})
		.then((res) => res.json())
		.then((json) => {
			console.log(document.getElementById("button_logout") ? true : false);
			game.innerHTML = json.body;
			if (json.nav) {
				document.getElementById("nav").innerHTML = json.nav;
				rebindEvents();
			}
			if (!isPong) {
				window.cancelAnimations();
				window.removeAllListeners("keyup");
				window.removeAllListeners("keydown");
			}else {
				if (window.refreshPongInputs)
					window.refreshPongInputs();	
			}
			loadPageScript(game);
		})
		.catch((err) => console.error("Error: ", err));
}

function handleHomeClick(ev) {
	ev.preventDefault();
	const url = "https://localhost";
	loadPage(document.getElementById("game"), url);
}

function handlePongClick(ev) {
	ev.preventDefault();
	const url = "https://localhost/pong";
	loadPage(document.getElementById("game"), url);
}

function handleAIPongClick(ev) {
	ev.preventDefault();
	const url = "https://localhost/pong";
	loadPage(document.getElementById("game"), url);
}

function handleLoginClick(ev) {
	ev.preventDefault();
	const url = "https://localhost/ssr/login";
	loadPage(document.getElementById("game"), url);
}

function handleRegisterClick(ev) {
	ev.preventDefault();
	const url = "https://localhost/ssr/register";
	loadPage(document.getElementById("game"), url);
}

function handleLogoutClick(ev) {
	ev.preventDefault();
	localStorage.removeItem("Authorization");
	const url = "https://localhost/ssr/login";
	loadPage(document.getElementById("game"), url);
}

function handleProfileClick(ev) {
	ev.preventDefault();
	const url = "https://localhost/profil";
	loadPage(document.getElementById("game"), url);
}

window.addEventListener("popstate", function (_) {
	const currentUrl = window.location.pathname;

	if (currentUrl !== window.location.pathname) {
		fetch(currentUrl, { headers: { "X-Requested-With": "XMLHttpRequest" } })
			.then((response) => response.text())
			.then((html) => {
				let game = document.getElementById("game");
				game.innerHTML = html;
			})
			.catch((err) => console.error("Error during popstate fetch: ", err));
	}
});

document.addEventListener("DOMContentLoaded", (ev) => {
	loadPage(
		document.getElementById("game"),
		window.location.href
	);
});