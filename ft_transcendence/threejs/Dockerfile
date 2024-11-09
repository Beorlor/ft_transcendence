# Utiliser l'image officielle Node.js 23 sur Alpine 3.19
FROM node:20-alpine3.19

# Définir le répertoire de travail
WORKDIR /app
ENV NODE_NO_WARNINGS=1

COPY app/ .

# Installer les dépendances, y compris three.js
RUN npm install

# Exposer le port sur lequel l'application va fonctionner (par exemple, 3000)
EXPOSE 4159

# Lancer l'application
CMD ["npx", "vite", "--port", "4159", "--host"]