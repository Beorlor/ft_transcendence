import { canvasHeight, barPadding,
	barWidth, barMoveSpeed, barHeight, 
	canvasWidth, goalWidth,
	ballRadius,
	barHitboxPadding,
	topHitbox,
	ballMaxSpeed,
	ballMoveSpeed,
	ballAcceleration} from "./constants.mjs";

var leftBar = 
{
	x: goalWidth,
	y: canvasHeight / 2 - (barHeight / 2),
	startX: goalWidth,
	startY: canvasHeight / 2 - (barHeight / 2),
	width: barWidth,
	height: barHeight,
	color: "#0000F0",
	moveSpeed: barMoveSpeed,
	ai: {},

	render: function (ctx){
		ctx.fillStyle = this.color;
		ctx.fillRect(this.x, this.y,
			this.width, this.height);
	},

	moveDown: function (timeStep){
		let newPos = this.y + (this.moveSpeed * timeStep);
		
		if (newPos < barPadding
			|| newPos + this.height > canvasHeight - barPadding)
			return ;
		this.y = newPos;
	},

	moveUp: function (timeStep){
		let newPos = this.y - (this.moveSpeed * timeStep);
		
		if (newPos < barPadding
			|| newPos + this.height > canvasHeight - barPadding)
			return ;
		this.y = newPos;
	},

	doesCollideHigh: function (y){
		let tmpY = y - this.y;

		if (tmpY < 0 || tmpY > this.height)
			return false;
		return (tmpY / this.height) < 0.5;
	},

	reset: function (){
		this.x = this.startX;
		this.y = this.startY;
	}
};

const rightBar = Object.assign({}, leftBar);
rightBar.x = canvasWidth - goalWidth - barWidth;
rightBar.startX = canvasWidth - goalWidth - barWidth;
rightBar.color = "#F00000"
rightBar.ai = {
	think_timer: 1.0,
	velY: 0.0,
	targetY: -1
};

var ball = 
{
	x: canvasWidth / 2 - ballRadius,
	y: canvasHeight / 2,
	radius: ballRadius,
	moveSpeed: ballMoveSpeed,
	maxMoveSpeed: ballMaxSpeed,
	velX: 0.0,
	velY: 0.0,
	color: "#00F000",

	render: function(ctx){
		drawBall(ctx, this);
	},
	
	update: function(deltaTime, game){
		let newX = this.x + this.velX * this.moveSpeed * deltaTime;
		let newY = this.y + this.velY * this.moveSpeed * deltaTime;
		
		if (newX <= 0 || newX < leftBar.x - this.radius * 4 || newX > rightBar.x + rightBar.width + this.radius * 4 || newX >= canvasWidth){
			this.reset();
			if (newX < canvasWidth / 2)
				game.aiScore++;
			else
				game.playerScore++;
			game.updateScore();
			game.playScoreSound();
			return ;
		}
		if ((newX <= leftBar.x + leftBar.width + barHitboxPadding && newY >= leftBar.y
			&& newY <= leftBar.y + leftBar.height)){
			newX = leftBar.x + leftBar.width + barHitboxPadding;
			this.velX *= -1;
			if (!leftBar.doesCollideHigh(newY))
				this.velY *= -1;
			game.playTouchSound();
		}
		else if (newX >= rightBar.x - barHitboxPadding && newY >= rightBar.y
					&& newY <= rightBar.y + rightBar.height){
			newX = rightBar.x - barHitboxPadding;
			this.velX *= -1;
			if (!rightBar.doesCollideHigh(newY))
				this.velY *= -1;
			game.playTouchSound();
		}
		if (newY <= topHitbox)
		{
			newY = topHitbox + 1;
			this.velY *= -1;
		}
		else if (newY >= canvasHeight - topHitbox)
		{
			newY = canvasHeight - topHitbox - 1;
			this.velY *= -1;
		}
		this.x = newX;
		this.y = newY;
		if (game.isGameStarted == true)
			this.moveSpeed += this.moveSpeed < this.maxMoveSpeed ? ballAcceleration * deltaTime : 0;
		
	},

	reset: function (){
		this.x = canvasWidth / 2 - ballRadius;
		this.y = canvasHeight / 2;
		this.velX = 0;
		this.velY = 0;
		this.moveSpeed = ballMoveSpeed;
	}
};

function drawBall(ctx, ball)
{
	ctx.beginPath();
	ctx.arc(ball.x - (ball.radius / 2),
		ball.y - (ball.radius / 2), ball.radius,
		0, 2 * Math.PI, false);
	ctx.fillStyle = ball.color;
	ctx.fill();
}

export {leftBar, rightBar, ball};