document.getElementById('form_validate_code').addEventListener('submit', function (event) {
    event.preventDefault();

    // Create a FormData object
    const formData = new FormData(this);

    // Convert FormData to a plain object
    const formObject = {};
    formData.forEach((value, key) => {
        formObject[key] = value;
    });

    // Send the request as JSON
    fetch('http://localhost:4567/auth/validate-code', {
        method: "POST",
        headers: {
            'Content-Type': 'application/json',
			'access_token': localStorage.getItem("access_token")
        },
        body: JSON.stringify(formObject)  // Convert the object to a JSON string
    })
    .then(response => response.json())  // Assuming server sends a JSON response
    .then(data => {
        console.log(data);  // Log response data
        if (data.code == 200) {
			console.log("Lezzz goo!");
        }
    })
    .catch(error => console.error('Error:', error));  // Log any errors
});