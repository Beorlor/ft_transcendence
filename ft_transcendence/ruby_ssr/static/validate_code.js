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

    fetch("http://localhost:4567/auth/validate-code", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        access_token: localStorage.getItem("access_token"),
      },
      body: JSON.stringify(formObject),
    })
      .then((response) => response.json())
      .then((data) => {
        console.log(data);
        if (data.success) {
          console.log("Lezzz goo!");
        } else {
          popUp.innerHTML = `<div class="alert alert-danger" role="alert">
              ${data.error}
              </div>`;
        }
      })
      .catch((error) => console.error("Error:", error));
  });
