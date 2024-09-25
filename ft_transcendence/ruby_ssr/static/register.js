function loadRegisterFormAction() {
  if (document.getElementById("form_register")) {
    document
      .getElementById("form_register")
      .addEventListener("submit", function (event) {
        event.preventDefault();

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
              localStorage.setItem("Authorization", data.access_token);
              window.loadPage(
                document.getElementById("game"),
                "https://localhost/vadilate-code",
                window.GAME_STATES.default
              );
            } else {
              popUp.innerHTML = `<div class="alert alert-danger" role="alert">
			  ${data.error}
			  </div>`;
            }
          })
          .catch((error) => console.error("Error:", error));
      });
  }
}

document.addEventListener("DOMContentLoaded", (_) => {
  if (!document.getElementById("game")) {
    let copy = document.body.innerHTML;
    document.body.innerHTML = "";
    fetch("https://localhost")
      .then((response) => response.text())
      .then((html) => {
        document.body.innerHTML = html;

        const script = document.body.querySelector("script");
        const newScript = document.createElement("script");

        newScript.type = "text/javascript";
        newScript.src = script.src;
        window.GAMESTATE = 0;
        document.body.appendChild(newScript);

        document.getElementById("game").innerHTML = copy;
        loadRegisterFormAction();
      });
  }
});

loadRegisterFormAction();
