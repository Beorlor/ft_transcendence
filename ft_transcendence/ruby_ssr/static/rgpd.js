function handleRGPDRequest(action) {
  let endpoint;
  switch (action) {
    case 'access':
      // Supposons que l'ID utilisateur soit disponible dans une variable `userId`
      endpoint = `/api/user/${userId}`;
      // Redirige vers la page de consultation des données personnelles
      window.location.href = endpoint;
      break;
    case 'rectify':
      window.location.href = '/edit-profile';
      break;
    case 'delete':
      if (confirm('Êtes-vous sûr de vouloir supprimer votre compte ? Cette action est irréversible.')) {
        endpoint = `/api/user/${userId}`;
        fetch(endpoint, { method: 'DELETE' })
          .then(response => {
            if (response.ok) {
              alert('Votre compte a été supprimé avec succès.');
              window.location.href = '/';
            } else {
              alert('Une erreur est survenue lors de la suppression de votre compte.');
            }
          });
      }
      break;
    case 'restrict':
      endpoint = `/api/rgpd/restrict/${userId}`;
      fetch(endpoint, { method: 'POST' })
        .then(response => {
          if (response.ok) {
            alert('Le traitement de vos données a été restreint.');
          } else {
            alert('Une erreur est survenue lors de la demande de restriction.');
          }
        });
      break;
    case 'portability':
      endpoint = `/api/rgpd/portability/${userId}`;
      window.location.href = endpoint;
      break;
    default:
      console.error('Action invalide');
  }
}

// Supposons que `userId` soit défini dans votre template ou défini via JavaScript
const userId = '<%= @user["id"] %>';
