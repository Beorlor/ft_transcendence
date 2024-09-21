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
	history.pushState()
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

window.loadPageScript = function (game){
	const script = game.querySelector("script");
	const newScript = document.createElement("script");
	newScript.type = "module";
	newScript.src = script.src;
	game.appendChild(newScript);
};

function loadPage(game, url){
	fetch(url, {headers: {'X-Requested-With': 'XMLHttpRequest'}})
		.then(res => res.text())
		.then(html => {
			game.innerHTML = html;
			window.loadPageScript(game);
		})
		.catch(err => console.error("Error: ", err));
}

function loadScript() {
	if (window.GAMESTATE > -1)
		return;
	let game = document.getElementById("game");
	if (game) {

		document.getElementById("home_link").addEventListener("click", (ev) => {
			ev.preventDefault();
			const url = "https://localhost";
			window.GAMESTATE = window.GAME_STATES.default;
			history.pushState(null, null, url);
			game.innerHTML = '';
		});

		document.getElementById("pong_link").addEventListener("click", (ev) => {
			ev.preventDefault();

			const url = "https://localhost/pong";
			window.GAMESTATE = window.GAME_STATES.pong;
			history.pushState(null, null, url);
			loadPage(game, url);
		});

		document.getElementById("aipong_link").addEventListener("click", (ev) => {
			ev.preventDefault();

			const url = "https://localhost/pong";
			window.GAMESTATE = window.GAME_STATES.aipong;
			history.pushState(null, null, url);
			loadPage(game, url);
		});

		document.getElementById("button_login").addEventListener("click", (ev) => {
			ev.preventDefault();

			const url = "https://localhost/ssr/login";
			window.GAMESTATE = window.GAME_STATES.default;
			history.pushState(null, null, url);
			loadPage(game, url);
		});

		document.getElementById("button_register").addEventListener("click", (ev) => {
			ev.preventDefault();

			const url = "https://localhost/ssr/register";
			window.GAMESTATE = window.GAME_STATES.default;
			history.pushState(null, null, url);
			loadPage(game, url);
		});

		window.GAMESTATE = 0;
	}
};

window.addEventListener('popstate', function(_) {
	const currentUrl = window.location.pathname;
	
	fetch(currentUrl, { headers: { 'X-Requested-With': 'XMLHttpRequest' } })
	  .then(response => response.text())
	  .then(html => {
		document.getElementById('game').innerHTML = html;
	  });
  });

document.addEventListener("DOMContentLoaded", (ev) => {
	loadScript();
});

loadScript();
