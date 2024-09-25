function loadValidateForm() {
  if (document.getElementById("form_validate_code")) {
    document
      .getElementById("form_validate_code")
      .addEventListener("submit", function (event) {
        event.preventDefault();

        const popUp = document.getElementById("pop-up");
        popUp.innerHTML = "";

        const formData = new FormData(this);
        const formObject = {};
        formData.forEach((value, key) => {
          formObject[key] = value;
        });

        fetch("https://localhost/auth/validate-code", {
          method: "POST",
          headers: {
            "Content-Type": "application/json",
            Authorization: localStorage.getItem("Authorization"),
          },
          body: JSON.stringify(formObject),
        })
          .then((response) => response.json())
          .then((data) => {
            console.log(data);
            if (data.success) {
              localStorage.setItem("Authorization", data.access_token);
              window.loadPage(
                document.getElementById("game"),
                "https://localhost/profil",
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
        window.GAMESTATE = 0;

        const script = document.body.querySelector("script");
        const newScript = document.createElement("script");

        newScript.type = "text/javascript";
        newScript.src = script.src;
        document.body.appendChild(newScript);

        document.getElementById("game").innerHTML = copy;
        loadValidateForm();
      });
  }
});

loadValidateForm();
