# 05 - Installation ClamAv

Depuis [Page docker hub](https://hub.docker.com/r/clamav/clamav-debian)
Depuis [le site](https://www.clamav.net)

- A plusieurs moments l'ipv4 utilisé pour SSH est `192.0.2.1`, prenez garde à bien le changer par le votre, en passant `192.0.2.1` est une IP de test réservée aux exemples, elle ne fonctionnera pas pour votre serveur.

## Prérequis

### Création du répertoire

On prépare un répertoire dans `opt/docker`

```bash
sudo mkdir -p /opt/docker/utils/clamav
cd /opt/docker/utils/clamav
```

### Création du `compose.yml`

On créé le `compose.yml`

```bash
sudo nano compose.yml
```

et on colle

```yaml
services:
  clamav:
    image: clamav/clamav-debian:stable
    container_name: clamav
    restart: unless-stopped
    volumes:
      - clamav_data:/var/lib/clamav
      - /:/vps:ro

volumes:
  clamav_data:
```

Et enregistrer le fichier.

## Création du conteneur

Et on lance le `compose up`

```bash
sudo docker compose up -d
```

On vérifie le statut du conteneur

```bash
sudo docker compose ps
```

## Lancer des scans

### Scan complet

```bash
sudo docker exec -it clamav clamscan -r --infected /vps -l /var/lib/clamav/rapport.log --append 2>/dev/null
```

### Dossiers utilisateurs

```bash
sudo docker exec -it clamav clamscan -r --infected /vps/home -l /var/lib/clamav/rapport.log --append 2>/dev/null
```

### Fichiers temporaires

```bash
sudo docker exec -it clamav clamscan -r --infected /vps/tmp -l /var/lib/clamav/rapport.log --append 2>/dev/null
```

### Conteneurs Docker

```bash
sudo docker exec -it clamav clamscan -r --infected /vps/opt/docker -l /var/lib/clamav/rapport.log --append 2>/dev/null
```

## Vérifier les rapport

```bash
sudo docker exec -it clamav egrep "FOUND|SUMMARY|Infected" /var/lib/clamav/rapport.log
```

Si virus, il retourne quelque chose du genre

```text
/vps/home/harry/un_fichier_suspect.exe: Eicar-Signature FOUND

----------- SCAN SUMMARY -----------
Infected files: 1
```

## Automatisation CRON

A faire plus tard, pas urgent
