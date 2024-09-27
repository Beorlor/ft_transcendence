function getQueryParams() {
  const params = new URLSearchParams(window.location.search);
  return params.get("code");
}

document.addEventListener("DOMContentLoaded", (ev) => {
  fetch("https://localhost/auth/callback", {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
    },
    body: JSON.stringify({ code: getQueryParams() }),
  })
    .then((res) => res.json())
    .then((json) => {
      if (json.success) {
        localStorage.setItem("Authorization", json.access_token);
        window.loadPage(
          document.getElementById("game"),
          "https://localhost/validate-code"
        );
      } else console.log("c'est la merde");
    });
});
