function loadLoginFormAction() {
	if (document.getElementById("form_login")) {
		document
			.getElementById("form_login")
			.addEventListener("submit", function (event) {
				event.preventDefault();

				const popUp = document.getElementById("pop-up");
				popUp.innerHTML = "";

				const formData = new FormData(this);
				const formObject = {};
				formData.forEach((value, key) => {
					formObject[key] = value;
				});

				fetch("https://localhost/auth/login", {
					method: "POST",
					headers: {
						"Content-Type": "application/json",
					},
					body: JSON.stringify(formObject),
				})
					.then((response) => response.json())
					.then((data) => {
						console.log(data);
						if (data.success) {
							localStorage.setItem("access_token", data.access_token);
							window.loadValidationCodePage();
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
		loadLoginFormAction();
	}
});

loadLoginFormAction();
