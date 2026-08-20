# 09 - Installation ClamAv

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
    security_opt:
      - no-new-privileges:true
    cap_drop:
      - ALL
    cap_add:
      - CHOWN
      - DAC_OVERRIDE
      - SETUID
      - SETGID
    network_mode: none
    volumes:
      - data:/var/lib/clamav
      - /:/vps:ro

  clamav-freshclam:
    image: clamav/clamav-debian:stable
    container_name: clamav-freshclam
    restart: "no"
    security_opt:
      - no-new-privileges:true
    cap_drop:
      - ALL
    cap_add:
      - CHOWN
      - DAC_OVERRIDE
      - SETUID
      - SETGID
    entrypoint: ["freshclam"]
    volumes:
      - data:/var/lib/clamav
    profiles:
      - update

volumes:
  data:
```

Et enregistrer le fichier.

**Pourquoi deux services :**

- `clamav` est le service de scan (`clamscan`). Il n'a jamais besoin du réseau pour comparer des fichiers à une base locale, il reste donc **totalement isolé** avec `network_mode: none` — aucun risque qu'il serve un jour de rebond réseau.
- `clamav-freshclam` est un service à part, dédié uniquement à la mise à jour de la base de signatures virales (`freshclam`), qui a besoin du réseau pour télécharger les mises à jour. Il partage le même volume `data` que le service de scan, donc la base qu'il télécharge est directement celle utilisée par `clamscan`.
- Le `profiles: - update` empêche ce service de démarrer avec un simple `docker compose up -d` — il ne se lance qu'à la demande (ou via le CRON, voir plus bas), et s'arrête de lui-même une fois la mise à jour terminée (`restart: "no"`).

Sans ce découpage, un `clamav` unique avec `network_mode: none` bloquerait aussi `freshclam`, qui tourne par défaut dans l'image au démarrage du conteneur : la base de signatures resterait alors figée à celle embarquée dans l'image au moment du build, et ne se mettrait plus jamais à jour.

## Création du conteneur

Et on lance le `compose up`

```bash
sudo docker compose up -d
```

Cette commande ne démarre que le service `clamav` (le scan) : `clamav-freshclam` étant sur le profil `update`, il n'est jamais lancé automatiquement.

On vérifie le statut du conteneur

```bash
sudo docker compose ps
```

## Mettre à jour la base de signatures (freshclam)

À lancer avant un scan si la base n'a jamais été mise à jour, puis régulièrement (voir Automatisation CRON plus bas) :

```bash
sudo docker compose --profile update run --rm clamav-freshclam
```

Le conteneur télécharge les dernières signatures dans le volume `data`, puis s'arrête et se supprime (`--rm`) automatiquement.

## Lancer des scans

### Scan complet

```bash
sudo docker exec -it clamav clamscan -r --infected /vps -l /var/lib/clamav/rapport.log -a 2>/dev/null
```

Attention, un scan complet est très long (au moins 30 minutes), il scanne l'intégralité des fichiers.

### Dossiers utilisateurs

```bash
sudo docker exec -it clamav clamscan -r --infected /vps/home -l /var/lib/clamav/rapport.log -a 2>/dev/null
```

### Fichiers temporaires

```bash
sudo docker exec -it clamav clamscan -r --infected /vps/tmp -l /var/lib/clamav/rapport.log -a 2>/dev/null
```

### Conteneurs Docker

```bash
sudo docker exec -it clamav clamscan -r --infected /vps/opt/docker -l /var/lib/clamav/rapport.log -a 2>/dev/null
```

## Vérifier les rapport

```bash
sudo docker exec -it clamav egrep "FOUND|SUMMARY|Infected" /var/lib/clamav/rapport.log
```

Si virus, il retourne quelque chose du genre

```text
/vps/home/paul/un_fichier_suspect.exe: Eicar-Signature FOUND

----------- SCAN SUMMARY -----------
Infected files: 1
```

## Automatisation CRON

A faire plus tard, pas urgent. Prévoir deux tâches distinctes :

- une tâche régulière (par exemple quotidienne) qui lance `sudo docker compose --profile update run --rm clamav-freshclam` pour tenir la base à jour ;
- une tâche de scan (fréquence à définir selon la charge du VPS, un scan complet étant long).
