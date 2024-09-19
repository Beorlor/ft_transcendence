const 	WINDOW_EVENTS = {};
const 	WINDOW_ANIMATIONS_FRAMES = [];
const GAME_STATES =
{
	"default": 0,
	"pong": 1,
	"aipong": 2,
	"threejs": 3
};
var		GAMESTATE = 0;

const addListener = (event, handler) => {
	if (!(event in WINDOW_EVENTS))
		WINDOW_EVENTS[event] = [];
	WINDOW_EVENTS[event] = handler;
	window.addEventListener(event, handler);
};

const removeAllListeners = (event) => {
	if (!(event in WINDOW_EVENTS))
		return ;
	for (handler in WINDOW_EVENTS[event])
		window.removeEventListener(event, handler);
	delete WINDOW_EVENTS[event];
};

const cancelAnimations = () => {
	for (v in WINDOW_ANIMATIONS_FRAMES)
		window.cancelAnimationFrame(v);
	WINDOW_ANIMATIONS_FRAMES.length = 0;
};

document.addEventListener("DOMContentLoaded", (ev) => {
	document.getElementById("home_link").addEventListener("click",
		function (){
			GAMESTATE = GAME_STATES.default;
			cancelAnimations();
			const game = document.getElementById("game");
			game.innerHTML = "";
		}
	);

	document.getElementById("pong_link").addEventListener("click",
		function (){
			fetch("/pong")
				.then(res => res.text())
				.then(html =>{
					const game = document.getElementById("game");
					GAMESTATE = GAME_STATES.pong;
					game.innerHTML = html;
					document.getElementById("game_name").textContent = "Pongpong";

					const script = game.querySelector('script');
					const newScript = document.createElement('script');
					newScript.type = 'module';
					newScript.src = script.src;
					game.appendChild(newScript);
				})
				.catch(error => console.error("Oh l'erreur !", error));
		}
	);
	
	document.getElementById("aipong_link").addEventListener("click",
		function (){
			fetch("/pong")
				.then(res => res.text())
				.then(html => {
					const game = document.getElementById("game");
					GAMESTATE = GAME_STATES.aipong;
					game.innerHTML = html;
					document.getElementById("game_name").textContent = "AI Pongpong";

					const script = game.querySelector('script');
					const newScript = document.createElement('script');
					newScript.type = 'module';
					newScript.src = script.src;
					game.appendChild(newScript);
				})
				.catch(error => console.error("Oh l'erreur !", error));
		}
	);

	document.getElementById("button_login").addEventListener("click",
		function (){
			fetch("/ssr/login")
				.then(res => res.text())
				.then(html => {
					GAMESTATE = GAME_STATES.default;
					cancelAnimations();
					const game = document.getElementById("game");
					game.innerHTML = html;
				});
		}
	);

	document.getElementById("button_register").addEventListener("click",
		function (){
			fetch("/ssr/register")
				.then(res => res.text())
				.then(html => {
					GAMESTATE = GAME_STATES.default;
					cancelAnimations();
					const game = document.getElementById("game");
					game.innerHTML = html;

					const script = game.querySelector('script');
					const newScript = document.createElement('script');
					newScript.type = 'module';
					newScript.src = script.src;
					game.appendChild(newScript);
				});
		}
	);
});
