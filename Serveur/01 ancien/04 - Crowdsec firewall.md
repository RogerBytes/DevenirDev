# 04 - Crowdsec firewall

## Prérequis

### Logs SSH avec rsyslog

```bash
sudo nala install -y rsyslog
```

On refait le fichier (docker l'a créé comme un répertoire, c'est normal)

```bash
sudo rm -rf /var/log/auth.log
sudo systemctl restart rsyslog
sleep 5
ls -la /var/log/auth.log
```

### Création des répertoires

```bash
sudo mkdir -p /opt/docker/crowdsec/config /opt/docker/crowdsec/data
```

### Réglage de surveillance via acquis.yaml

```bash
sudo nano /opt/docker/crowdsec/config/acquis.yaml
```

On y met

```yml
filenames:
  - /var/log/auth.log
labels:
  type: syslog
```

### Le compose

```bash
sudo nano /opt/docker/crowdsec/compose.yml
```

On y met

```yml
services:
  crowdsec:
    image: crowdsecurity/crowdsec:latest
    container_name: crowdsec
    restart: unless-stopped
    environment:
      COLLECTIONS: "crowdsecurity/sshd crowdsecurity/linux"
    volumes:
      - /opt/docker/crowdsec/config/acquis.yaml:/etc/crowdsec/acquis.yaml:ro
      - /opt/docker/crowdsec/data:/var/lib/crowdsec/data
      - /var/log/auth.log:/var/log/auth.log:ro
    ports:
      - "127.0.0.1:8080:8080"
```

Et on protège les accès

```bash
sudo chmod 600 /opt/docker/crowdsec/compose.yml
```

## Création du conteneur

```bash
cd /opt/docker/crowdsec
sudo docker compose up -d
```

## Installation du bouncer crowdsec du pare-feu

Info depuis le [le site de crowdsec](https://doc.crowdsec.net/u/getting_started/installation/linux).

On installe le repo

```bash
curl -s https://install.crowdsec.net | sudo sh
```

Puis on installe le paquet

```bash
sudo nala install -y crowdsec-firewall-bouncer-iptables
```

On crée une clef API pour le bouncer dans le conteneur

```bash
sudo docker exec crowdsec cscli bouncers add firewall-bouncer
```

On garde la clef précieusement er on édite le fichier pour remplacer la valeur de `api_key:` par notre nouvelle clef :

```bash
sudo nano /etc/crowdsec/bouncers/crowdsec-firewall-bouncer.yaml
```

Dans `/etc/crowdsec/bouncers/crowdsec-firewall-bouncer.yaml`, dans la partie `iptables_chains:` il faut dé- commenter `#  - DOCKER-USER`

On enregistre, et on met les droits

```bash
sudo chmod 600 /etc/crowdsec/bouncers/crowdsec-firewall-bouncer.yaml
```

et on relance

```bash
sudo systemctl restart crowdsec-firewall-bouncer
```

puis on surveille

```bash
sudo systemctl status crowdsec-firewall-bouncer
```

Il doit retourner

```text
● crowdsec-firewall-bouncer.service - The firewall bouncer for CrowdSec
     Loaded: loaded (/etc/systemd/system/crowdsec-firewall-bouncer.service; enabled; preset: enabled)
     Active: active (running) since Tue 2026-06-30 10:11:50 UTC; 3s ago
 Invocation: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
    Process: 962008 ExecStartPre=/usr/bin/crowdsec-firewall-bouncer -c /etc/crowdsec/bouncers/crowdsec-firewall-bouncer.yaml -t (code=exited, status=0/SUCCESS)
    Process: 962060 ExecStartPost=/bin/sleep 0.1 (code=exited, status=0/SUCCESS)
   Main PID: 962036 (crowdsec-firewa)
      Tasks: 8 (limit: 9257)
     Memory: 8.2M (peak: 10.2M)
        CPU: 167ms
     CGroup: /system.slice/crowdsec-firewall-bouncer.service
             └─962036 /usr/bin/crowdsec-firewall-bouncer -c /etc/crowdsec/bouncers/crowdsec-firewall-bouncer.yaml

Jun 30 10:11:43 vps-59944032 systemd[1]: Starting crowdsec-firewall-bouncer.service - The firewall bouncer for CrowdSec...
Jun 30 10:11:50 vps-59944032 systemd[1]: Started crowdsec-firewall-bouncer.service - The firewall bouncer for CrowdSec.
```

et on vérifie côté Docker

```bash
sudo docker exec crowdsec cscli bouncers list
```

`firewall-bouncer` doit apparaître dans la liste

## Test de métrique

Pour faire un test de métrique faire

```bash
sudo docker exec crowdsec cscli metrics
```

Les `Lines unparsed: 47`, c'est normal, c'est des lignes lues et ne posant aucun problème de sécurité.

## Voir les décision de CrowdSec

Permet de voir les actions entreprises par CrowdSec, genre les ip bannies

```bash
sudo docker exec crowdsec cscli decisions list
```
