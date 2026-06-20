# A gérer ranger ou supprimer, à voir quoi

Les volumes servent à stocker deux types de données, les fichiers persistants, type images de profils, les pdf, les images, les avatars, médias etc (souvent dans le public)

et les bases de données

conclusion
Le conteneur ne contient que du code jetable. Tout ce qui est précieux et qui est créé pendant que l'application tourne (fichiers médias, uploads, bases de données) doit obligatoirement être rangé dans un volume ou un bind mount sur ton VPS.

!!! explication du reverse proxy nginx

C'est le secrétaire ou le réceptionniste de ton VPS.

Au lieu que les utilisateurs du web frappent directement aux portes de tes conteneurs Docker, ils parlent tous au Reverse Proxy (sur les ports standards 80 et 443). C'est lui qui prend les demandes, gère la sécurité (le HTTPS/SSL), et les distribue discrètement au bon conteneur en arrière-plan.

et sur mon VPS OVH j'ai une protection VAC, qui permet de protéger contre les attaques DDOS d'ampleur

Sur un VPS, Docker contourne UFW par défaut : pour sécuriser tes conteneurs, force-les toujours à écouter sur le localhost en écrivant `127.0.0.1:port:port` dans ton fichier compose.
