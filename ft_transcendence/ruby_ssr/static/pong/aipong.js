import { leftBar, rightBar, ball } from "./game_objects.mjs";
import { canvasWidth, canvasHeight, timeStep,
			topHitbox, winningScore, barPadding, 
			barHitboxPadding} from "./constants.mjs";

/* TODO
	DONE - Peaufiner les collisions
	DONE - Mouvements de la balle
	DONE - Ajout du score de la partie
	DONE - Ajout d'un ecran de debut de partie
	DONE - Ecran de fin de partie
	DONE - Clean le code
	DONE - Fix le probleme du message infini si la balle est derriere une des barres
	DONE - Ajouter un cadre pour delimiter l'ecran de jeu
	- Calculer un meilleur angle de renvoi de la balle
	- BONUS
		- Petite musique
		- Images plutot que de simples couleurs
		- Petit easter egg
*/

function pong_main()
{
	let		previousTime = 0.0;
	let		delta = 0.0;

	let		upPressed = false;
	let		downPressed = false;

	let		debugMode = false;
	let		wPressed = false;
	let		sPressed = false;

	let		hasAI = true;

	const Game = 
	{
		playerScore: 0,
		aiScore: 0,
		timer: 0,
		isGameStarted: false,
		winner: -1, // -1 -> No winner, 0 -> Player won, 1 -> Ai won
		touchSound: new Audio("/static/sounds/bonk.mp3"),
		scoreSound: new Audio("/static/sounds/winSound.mp3"),

		updateScore: function (){
			let scoreText = document.getElementById("score_text");
			if (scoreText){
				scoreText.textContent = this.playerScore + " - " + this.aiScore;
				if (this.playerScore >= winningScore)
					this.winner = 0;
				else if (this.aiScore >= winningScore)
					this.winner = 1;
				let winnerText = document.getElementById("winner_text");
				if (winnerText){
					if (this.winner > -1){
						winnerText.setAttribute("style", "color: black;");
						winnerText.textContent = (this.winner == 0 ? "Player1" : "Player2") + " won !";
					}
					else
						winnerText.setAttribute("style", "color: white;");
				}
			}
		},

		reset: function ()
		{
			this.aiScore = 0;
			this.playerScore = 0;
			this.timer = 0;
			this.winner = -1;
			this.updateScore();
		},

		playTouchSound: function (){
			this.touchSound.volume = 0.2;
			this.touchSound.play();
		},

		playScoreSound: function (){
			this.scoreSound.volume = 0.2;
			this.scoreSound.play();
		}
	};

	const loop = time => 
	{
		const dt = time - previousTime;

		delta += dt;
		previousTime = time;
		while (delta > timeStep)
		{
			gameLoop(delta / 100000);
			delta -= timeStep;
		}
		drawLoop();
		WINDOW_ANIMATIONS_FRAMES.push(window.requestAnimationFrame(loop));
	}

	/**
	 * 
	 * @param {number} deltaTime Rendering time difference between two frames
	 */
	function drawLoop()
	{
		const canvas = document.getElementById("drawCanvas");
		if (canvas.getContext)
		{
			const ctx = canvas.getContext("2d");
			ctx.clearRect(0, 0, canvasWidth, canvasHeight);
			ctx.fillStyle = "#000000";
			ctx.fillRect(0, 0, canvasWidth, canvasHeight);
			ctx.clearRect(topHitbox / 2, topHitbox / 2, canvasWidth - topHitbox, canvasHeight - topHitbox);
			leftBar.render(ctx);
			rightBar.render(ctx);
			ball.render(ctx);
		}
	}

	function gameLoop(dt)
	{
		if (upPressed && Game.isGameStarted)
			leftBar.moveUp(dt);
		else if(downPressed && Game.isGameStarted)
			leftBar.moveDown(dt);
		if (wPressed && Game.isGameStarted && !hasAI)
			rightBar.moveUp(dt);
		else if (sPressed && Game.isGameStarted && !hasAI)
			rightBar.moveDown(dt);
		if (hasAI)
			rightBarAI(dt, Game);
		ball.update(dt, Game);
		if (ball.velX == 0 && Game.isGameStarted)
		{
			Game.isGameStarted = false;
			leftBar.reset();
			rightBar.reset();
		}
	}

	function rightBarAI(dt, game)
	{
		rightBar.ai.think_timer -= dt;
		if (rightBar.ai.think_timer <= 0.0)
		{
			let start = {x: ball.x, y: ball.y};
			let vY = ball.velY;
			if (vY != 0 && ball.velX > 0){
				while (true){
					start.x += ball.velX * ball.moveSpeed * dt;
					start.y += vY * ball.moveSpeed * dt;
					if (start.x >= rightBar.x - barHitboxPadding)
						break ;
					if (start.y <= topHitbox || start.y >= canvasHeight - topHitbox)
						vY *= -1;
				}
				rightBar.ai.targetY = start.y - rightBar.height / 2;
				rightBar.ai.think_timer = 1.0;
			}
		}
		if (rightBar.ai.targetY > 0 && game.isGameStarted){
			if (rightBar.ai.targetY < rightBar.y && rightBar.y >= topHitbox)
				rightBar.y -= rightBar.moveSpeed * dt;
			if (rightBar.ai.targetY > rightBar.y && rightBar.y + rightBar.height <= canvasHeight - topHitbox)
				rightBar.y += rightBar.moveSpeed * dt;
		}
	}

	function startGame()
	{
		let start_text = document.getElementById("start_text");
		if (!start_text)
			return ;
		if (Game.winner > -1){
			Game.reset();
			start_text.setAttribute("style", "color: black;");
		}
		else {
			start_text.setAttribute("style", "color: white;");
			Game.isGameStarted = true;
			ball.velX = (1 - 2 * (Math.round(Math.random()))) * ball.moveSpeed;
			ball.velY = (1 - 2 * (Math.round(Math.random()))) * ball.moveSpeed;
		}
	}

	WINDOW_ANIMATIONS_FRAMES.push(window.requestAnimationFrame(time => {
		let game_info_text = document.getElementById("game_info_text");
		previousTime = time;
	
		if (game_info_text)
			game_info_text.textContent = "First to " + winningScore + " points wins !";
		addListener("keydown", (ke) => {
			if (ke.key == "w" && !ke.repeat)
				wPressed = true;
			else if (ke.key == "s" && !ke.repeat)
				sPressed = true;
			if (ke.key == "ArrowUp" && !ke.repeat)
				upPressed = true;
			else if (ke.key == "ArrowDown" && !ke.repeat)
				downPressed = true;
			else if (ke.key == " " && ball.velX == 0)
				startGame();
			else if (ke.key == "O") {
				debugMode = !debugMode;
				console.log("Debug mode " + (debugMode ? "activated" : "deactivated"));
			}
		});
	
		addListener("keyup", (ke) => {
			if (ke.key == "ArrowUp" && !ke.repeat)
				upPressed = false;
			if (ke.key == "ArrowDown" && !ke.repeat)
				downPressed = false;
			if (ke.key == "w" && !ke.repeat)
				wPressed = false;
			if (ke.key == "s" && !ke.repeat)
				sPressed = false;
		});
		WINDOW_ANIMATIONS_FRAMES.push(window.requestAnimationFrame(loop));
	}));
}
pong_main();
