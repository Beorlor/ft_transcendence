const makeBar = (x, y, width, height) => {
  return {
    x: x,
    y: y,
    width: width,
    height: height,
    color: "#0000F0",

    render: function (ctx) {
      ctx.fillStyle = this.color;
      ctx.fillRect(this.x, this.y, this.width, this.height);
    },
  };
};

const makeBall = (x, y, radius) => {
  return {
    x: x,
    y: y,
    radius: radius,
    color: "#00F000",

    render: function (ctx) {
      ctx.beginPath();
      ctx.arc(
        this.x - this.radius / 2,
        this.y - this.radius / 2,
        this.radius,
        0,
        2 * Math.PI,
        false
      );
      ctx.fillStyle = this.color;
      ctx.fill();
    },
  };
};

function updateTimer(endTime, timerInterval) {
  const now = new Date();
  const timeRemaining = endTime - now; // Temps restant en millisecondes

  if (timeRemaining <= 0) {
    document.getElementById("timer").innerText =
      "Le tournoi commence maintenant!";
    clearInterval(timerInterval); // Arrêter le minuteur lorsque le temps est écoulé
  } else {
    const minutes = Math.floor(timeRemaining / 1000 / 60);
    const seconds = Math.floor((timeRemaining / 1000) % 60);
    document.getElementById(
      "timer"
    ).innerText = `Temps restant: ${minutes}m ${seconds}s`;
  }
}

/* rueifrwhfreuywghwuighvrnicjmowobuuhjvimrfkruqotnhijmrvobqnivmrcqbjnmkv
yvquicjodknjqouhvijmrocki brinqvmokclewvognrqbmviopc,w[r  evnbivom  pw  rbniu
bvvwhrnjcmekdl,ckfvimwbguijmvoqc,vmreiqbtnuimvqoc,pem rnbiutmvo] */

function startTournamentGame() {
  const tournamentId = document
    .getElementById("game_name")
    .getAttribute("data-tournament-id");
  const url = `wss://localhost/pongsocket/tournament/${tournamentId}`;
  const connection = new WebSocket(url);
  const canvas = document.getElementById("drawCanvas");
  const ball = makeBall(400, 300, 10);
  const leftBar = makeBar(10, 250, 10, 100);
  leftBar.color = "#F00000";
  const rightBar = makeBar(780, 250, 10, 100);
  let timerInterval = null;

  connection.onopen = () => {
    connection.send("Hello from the client!");
    document.getElementById("score_text").innerHTML =
      '<div class="spinner-border" role="status"> <span class="sr-only">Loading...</span></div>';
  };

  connection.onmessage = (event) => {
    let json = JSON.parse(event.data);
    console.log(json);
    if (json.status === "Waiting") {
      timerInterval = setInterval(() => {
        updateTimer(new Date(json.time_end), timerInterval);
      }, 1000);
      document.getElementById("score_text").innerHTML =
        "En attente d'un adversaire...";
      return;
    } else if (json.status === "end") {
      document.getElementById("score_text").innerHTML =
        "Le tournoi est terminé!";
      clearInterval(timerInterval);
      return;
    }
    // if (!canvas) return;
    // if (canvas.getContext) {

    //   const ctx = canvas.getContext("2d");
    //   ctx.clearRect(0, 0, 800, 600);
    //   ctx.fillStyle = "#000000";
    //   ctx.fillRect(0, 0, 800, 600);
    //   ctx.clearRect(10 / 2, 10 / 2, 800 - 10, 600 - 10);
    //   if (json.paddle2_y) {
    //     rightBar.y = json.paddle2_y;
    //   }
    //   if (json.paddle1_y) {
    //     leftBar.y = json.paddle1_y;
    //   }
    //   if (json.ball_x && json.ball_y) {
    //     ball.x = json.ball_x;
    //     ball.y = json.ball_y;
    //   }
    //   leftBar.render(ctx);
    //   rightBar.render(ctx);
    //   ball.render(ctx);
    // }
  };

  connection.onclose = () => {
    clearInterval(timerInterval);
    window.loadPage(
      document.getElementById("game"),
      "https://localhost/tournaments"
    );
  };

  connection.onerror = (error) => {
    console.error("Erreur WebSocket :", error);
  };

  window.addEventListener("keydown", (event) => {
    if (event.key === "ArrowUp") {
      connection.send('{ "direction": "up" }');
    } else if (event.key === "ArrowDown") {
      connection.send('{ "direction": "down" }');
    }
  });

  window.addEventListener("keyup", (event) => {
    if (event.key === "ArrowUp" || event.key === "ArrowDown") {
      connection.send('{ "direction": null }');
    }
  });
}

window.addEventListener("DOMContentLoaded", (_) => {
  startTournamentGame();
});

window.startNormalGame = startTournamentGame;
