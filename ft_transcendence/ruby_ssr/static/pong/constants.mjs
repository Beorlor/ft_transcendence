const	canvasWidth = 800;
const	canvasHeight = 600;

const	winningScore = 2;

let		barWidth = 12;
let		barHeight = 120;
const	barPadding = 10;
const	barMoveSpeed = 200;
const	barHitboxPadding = 3;

const	topHitbox = 10;

let		ballRadius = 8;
let		ballMoveSpeed = 12;
let		ballMaxSpeed = 64;
let		ballAcceleration = 0.30;

const	goalWidth = 50;

const	timeStep = 1.0 / 60.0;

export {canvasWidth, canvasHeight, barWidth, barPadding,
		timeStep, barMoveSpeed, barHeight, goalWidth, ballRadius,
		barHitboxPadding, topHitbox, ballMoveSpeed, ballMaxSpeed,
		ballAcceleration, winningScore};