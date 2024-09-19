// username
// email
// password
// password_confirmation

// Intercepter la soumission du formulaire
document.getElementById('form_register').addEventListener('submit', function (event) {
    event.preventDefault();

    // Create a FormData object
    const formData = new FormData(this);

    // Convert FormData to a plain object
    const formObject = {};
    formData.forEach((value, key) => {
        formObject[key] = value;
    });

	const username = formData.get('username');

    // Afficher les informations du formulaire dans la console
    console.log(`Vous avez soumis le nom : ${username}`);

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
            alert('Registration successful!');
        } else {
            alert('Registration failed: ' + data.message);
        }
    })
    .catch(error => console.error('Error:', error));  // Log any errors
});