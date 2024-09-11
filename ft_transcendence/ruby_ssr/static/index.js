document.addEventListener("DOMContentLoaded", () => {
	document.getElementById("pong_link").addEventListener("click",
		function (){
			fetch("/pong")
				.then(res => res.text())
				.then(html =>{
					document.getElementById("game").innerHTML = html;
				})
				.catch(error => console.error("Oh l'erreur !", error));
		}
	);
});