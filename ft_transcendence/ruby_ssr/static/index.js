const WINDOW_EVENTS = {};
const WINDOW_ANIMATIONS_FRAMES = [];

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
	document.getElementById("pong_link").addEventListener("click",
		function (){
			fetch("/pong")
				.then(res => res.text())
				.then(html =>{
					const game = document.getElementById("game");
					cancelAnimations();
					removeAllListeners("keydown");
					removeAllListeners("keyup");
					game.innerHTML = html;

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
			fetch("/aipong")
				.then(res => res.text())
				.then(html =>{
					const game = document.getElementById("game");
					cancelAnimations();
					removeAllListeners("keydown");
					removeAllListeners("keyup");
					delete window.Game;
					game.innerHTML = html;

					const script = game.querySelector('script');
					const newScript = document.createElement('script');
					newScript.type = 'module';
					newScript.src = script.src;
					game.appendChild(newScript);
				})
				.catch(error => console.error("Oh l'erreur !", error));
		}
	);
});