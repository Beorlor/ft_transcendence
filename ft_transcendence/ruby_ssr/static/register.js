document
  .getElementById("form_register")
  .addEventListener("submit", function (event) {
    event.preventDefault();

    console.log("register");

    const popUp = document.getElementById("pop-up");
    popUp.innerHTML = "";

    const formData = new FormData(this);
    const formObject = {};
    formData.forEach((value, key) => {
      formObject[key] = value;
    });

    fetch("https://localhost/auth/register", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify(formObject),
    })
      .then((response) => response.json())
      .then((data) => {
        if (data.success) {
          localStorage.setItem("access_token", data.access_token);
          fetch("/validate-code")
            .then((response) => response.text())
            .then((html) => {
              GAMESTATE = GAME_STATES.default;
              cancelAnimations();
              const game = document.getElementById("game");
              game.innerHTML = html;

              const script = game.querySelector("script");
              const newScript = document.createElement("script");
              newScript.type = "module";
              newScript.src = script.src;
              game.appendChild(newScript);
            });
        } else {
          popUp.innerHTML = `<div class="alert alert-danger" role="alert">
            ${data.error}
            </div>`;
        }
      })
      .catch((error) => console.error("Error:", error));
  });
