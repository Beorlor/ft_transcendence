document.getElementById('form_register').addEventListener('submit', function (event) {
    event.preventDefault();

    // Create a FormData object
    const formData = new FormData(this);

    // Convert FormData to a plain object
    const formObject = {};
    formData.forEach((value, key) => {
        formObject[key] = value;
    });

    // Send the request as JSON
    fetch('http://localhost:4567/auth/register', {
        method: "POST",
        headers: {
            'Content-Type': 'application/json'  // Expecting JSON
        },
        body: JSON.stringify(formObject)  // Convert the object to a JSON string
    })
    .then(response => response.json())  // Assuming server sends a JSON response
    .then(data => {
        console.log(data);  // Log response data
        if (data.success) {
			localStorage.setItem("access_token", data.access_token);
			fetch("/validate-code")
				.then(response => response.text())
				.then(html => {
					GAMESTATE = GAME_STATES.default;
					cancelAnimations();
					const game = document.getElementById("game");
					game.innerHTML = html;

					const script = game.querySelector('script');
					const newScript = document.createElement('script');
					newScript.type = 'module';
					newScript.src = script.src;
					game.appendChild(newScript);
				});	
        }
    })
    .catch(error => console.error('Error:', error));  // Log any errors
});