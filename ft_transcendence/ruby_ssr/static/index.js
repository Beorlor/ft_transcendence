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
	delete WINDOW_EVENTS[event];
};

window.cancelAnimations = () => {
	for (let v in WINDOW_ANIMATIONS_FRAMES) window.cancelAnimationFrame(v);
	WINDOW_ANIMATIONS_FRAMES.length = 0;
};

function loadScript() {
	if (window.GAMESTATE > -1)
		return;
	document.getElementById("home_link").addEventListener("click", function () {
		const popUp = document.getElementById("pop-up");
		popUp.innerHTML = "";
		window.GAMESTATE = window.GAME_STATES.default;
		window.cancelAnimations();
		const game = document.getElementById("game");
		game.innerHTML = "";
	});

	document.getElementById("pong_link").addEventListener("click", function () {
		const popUp = document.getElementById("pop-up");
		popUp.innerHTML = "";
		fetch("https://localhost/pong")
			.then((res) => res.text())
			.then((html) => {
				const game = document.getElementById("game");
				window.GAMESTATE = window.GAME_STATES.pong;
				game.innerHTML = html;
				document.getElementById("game_name").textContent = "Pongpong";

				const script = game.querySelector("script");
				const newScript = document.createElement("script");
				newScript.type = "module";
				newScript.src = script.src;
				game.appendChild(newScript);
			})
			.catch((error) => console.error("Oh l'erreur !", error));
	});

	document.getElementById("aipong_link").addEventListener("click", function () {
		const popUp = document.getElementById("pop-up");
		popUp.innerHTML = "";
		fetch("https://localhost/pong")
			.then((res) => res.text())
			.then((html) => {
				const game = document.getElementById("game");
				window.GAMESTATE = window.GAME_STATES.aipong;
				game.innerHTML = html;
				document.getElementById("game_name").textContent = "AI Pongpong";

				const script = game.querySelector("script");
				const newScript = document.createElement("script");
				newScript.type = "module";
				newScript.src = script.src;
				game.appendChild(newScript);
			})
			.catch((error) => console.error("Oh l'erreur !", error));
	});

	document
		.getElementById("button_login")
		.addEventListener("click", function () {
			const popUp = document.getElementById("pop-up");
			popUp.innerHTML = "";
			fetch("https://localhost/ssr/login")
				.then((res) => res.text())
				.then((html) => {
					window.GAMESTATE = window.GAME_STATES.default;
					window.cancelAnimations();
					const game = document.getElementById("game");
					game.innerHTML = html;

					const script = game.querySelector("script");
					const newScript = document.createElement("script");
					newScript.type = "module";
					newScript.src = script.src;
					game.appendChild(newScript);
				});
		});

	document
		.getElementById("button_register")
		.addEventListener("click", function () {
			const popUp = document.getElementById("pop-up");
			popUp.innerHTML = "";
			fetch("https://localhost/ssr/register")
				.then((res) => res.text())
				.then((html) => {
					window.GAMESTATE = window.GAME_STATES.default;
					window.cancelAnimations();
					const game = document.getElementById("game");
					game.innerHTML = html;

					const script = game.querySelector("script");
					const newScript = document.createElement("script");
					newScript.type = "module";
					newScript.src = script.src;
					game.appendChild(newScript);
				});
		});
	window.GAMESTATE = 0;
}

document.addEventListener("DOMContentLoaded", (ev) => {
	loadScript();
});

loadScript();
