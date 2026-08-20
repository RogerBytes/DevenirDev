# 04 - WireGuard

WireGuard va créer un réseau privé chiffré entre le VPS entreprise et les futurs VPS produits, afin que HashiCorp Vault (doc 05) ne soit jamais exposé sur l'IP publique.

Contrairement aux autres briques de l'infra, WireGuard **s'installe directement sur l'hôte** (comme UFW ou le bouncer pare-feu CrowdSec), et non en conteneur Docker, car il a besoin d'un accès direct au noyau réseau.

- A plusieurs moments l'ipv4 utilisé est `192.0.2.1`, prenez garde à bien le changer par la votre, elle est uniquement là à titre d'exemple.
- A plusieurs moments le port UDP utilisé est `51820`, c'est le port par défaut de WireGuard, vous pouvez le changer si vous le souhaitez.

## Schéma d'adressage

Le réseau privé utilisé est `10.10.0.0/16`, découpé par groupe pour rester lisible même avec plusieurs SaaS et plusieurs VPS par SaaS :

| Plage | Usage |
| --- | --- |
| `10.10.0.1` | VPS entreprise (hub, héberge Vault) |
| `10.10.1.x` | VPS du SaaS n°1 (x = 1, 2, 3... selon le nombre de serveurs) |
| `10.10.2.x` | VPS du SaaS n°2 |
| `10.10.3.x` | VPS du SaaS n°3 |
| ... | ... |

Chaque nouveau SaaS reçoit ainsi son propre bloc `/24` (254 adresses possibles), largement suffisant même en cas de forte charge nécessitant plusieurs VPS par produit. Le VPS entreprise (`10.10.0.1`) est le seul point central : c'est une topologie en étoile, les VPS produits ne se parlent jamais entre eux, ils ne parlent qu'au hub.

## Installation sur le VPS entreprise (hub)

<details><summary class="button">🔍 Spoiler</summary><div class="spoiler">

### Installation du paquet

```bash
sudo nala install -y wireguard
```

### Génération des clefs du hub

```bash
sudo bash -c '
cd /etc/wireguard/keys
umask 077
wg genkey | tee hub-private.key | wg pubkey | tee hub-public.key
chmod 600 hub-private.key
'
```

On note précieusement le contenu de `hub-public.key`, il servira à chaque futur peer.

```bash
sudo cat /etc/wireguard/keys/hub-public.key
```

### Activation du routage IP (nécessaire pour que le hub fasse transiter le trafic)

```bash
sudo nano /etc/sysctl.d/99-wireguard.conf
```

```conf
net.ipv4.ip_forward = 1
```

On applique

```bash
sudo sysctl --system
```

### Création du fichier de configuration `wg0.conf`

On récupère notre clef privé

```bash
sudo cat /etc/wireguard/keys/hub-private.key
```

On note précieusement la clef pour ce qui suit.

```bash
sudo nano /etc/wireguard/wg0.conf
```

```ini
[Interface]
Address = 10.10.0.1/16
ListenPort = 51820
PrivateKey = <CONTENU DE hub-private.key>

# ----------- Peers (VPS produits) ------------ #
```

On protège l'accès

```bash
sudo chmod 600 /etc/wireguard/wg0.conf
```

### Ouverture du port dans UFW

Le port doit être ouvert, mais en liste blanche des IP publiques de vos futurs VPS produits uniquement (à ajouter au fur et à mesure que vous en créez).

Remplacer `192.0.2.1` par l'ip de la machine (jamais celle du hub lui-même — cette règle sert uniquement à autoriser une machine distante à se connecter, pas à ce que le hub s'autorise lui-même).

```bash
sudo ufw allow from 192.0.2.1 to any port 51820 proto udp comment 'WireGuard - VPS Produit 1'
```

On autorise aussi tout le trafic déjà déchiffré arrivant depuis l'interface WireGuard elle-même (indispensable même sur le hub, sinon le pare-feu bloquera le trafic même une fois le tunnel établi) :

```bash
sudo ufw allow in on wg0
```

On recharge UFW

```bash
sudo ufw reload
```

### Activation du service

```bash
sudo systemctl enable --now wg-quick@wg0
```

On vérifie

```bash
sudo systemctl status wg-quick@wg0
sudo wg show
```

`Active: active (running)` et une interface `wg0` avec la bonne `public key` confirment que le hub est prêt.

Et on regarde si l'adressage est bonne

```bash
ip addr show wg0
```

Il doit retourner

```bash
8: wg0: <POINTOPOINT,NOARP,UP,LOWER_UP> mtu 1420 qdisc noqueue state UNKNOWN group default qlen 1000
    link/none
    inet 10.10.0.1/16 scope global wg0
       valid_lft forever preferred_lft forever
```

</div></details>

## Ajout d'un premier VPS produit (peer)

<details><summary class="button">🔍 Spoiler</summary><div class="spoiler">

À répéter pour chaque nouveau VPS produit, en changeant l'adresse IP privée attribuée (`10.10.1.1`, `10.10.1.2`, etc. selon le schéma d'adressage plus haut).

### Sur le VPS produit : installation et génération des clefs

```bash
sudo nala install -y wireguard
sudo mkdir -p /etc/wireguard/keys
cd /etc/wireguard/keys
umask 077
wg genkey | sudo tee peer-private.key | wg pubkey | sudo tee peer-public.key
sudo chmod 600 peer-private.key
```

On note le contenu de `peer-public.key`.

```bash
cat /etc/wireguard/keys/peer-public.key
```

### Sur le VPS produit : fichier de configuration

```bash
sudo nano /etc/wireguard/wg0.conf
```

```ini
[Interface]
Address = 10.10.1.1/16
PrivateKey = <CONTENU DE peer-private.key>

[Peer]
PublicKey = <CONTENU DE hub-public.key>
Endpoint = 192.0.2.1:51820
AllowedIPs = 10.10.0.0/16
PersistentKeepalive = 25
```

- `Endpoint` : IP publique du VPS entreprise (le hub).
- `AllowedIPs = 10.10.0.0/16` : le peer ne route que le trafic destiné au réseau privé WireGuard, jamais tout son trafic (pas de tunnel complet, seulement l'accès à Vault et au réseau interne).
- `PersistentKeepalive = 25` : indispensable pour que le tunnel reste actif à travers le NAT du fournisseur VPS, sinon la connexion peut se couper silencieusement.

On protège l'accès

```bash
sudo chmod 600 /etc/wireguard/wg0.conf
```

### Sur le VPS produit : activation

```bash
sudo systemctl enable --now wg-quick@wg0
```

### Sur le VPS entreprise (hub) : ajout du peer

On édite à nouveau le fichier du hub

```bash
sudo nano /etc/wireguard/wg0.conf
```

À la fin, dans la partie `Peers`, on ajoute

```ini
[Peer]
# VPS Produit 1
PublicKey = <CONTENU DE peer-public.key>
AllowedIPs = 10.10.1.1/32
```

`AllowedIPs` ici restreint strictement quelle IP privée ce peer a le droit d'utiliser — même si la clef était compromise, elle ne pourrait pas usurper une autre IP du réseau.

On recharge la configuration sans couper le service

```bash
sudo wg syncconf wg0 <(sudo wg-quick strip wg0)
```

### Ouverture de l'IP publique du peer dans UFW (sur le hub)

```bash
sudo ufw allow from 192.0.2.1 to any port 51820 proto udp comment 'WireGuard - VPS Produit 1'
sudo ufw reload
```

</div></details>

## Vérification

<details><summary class="button">🔍 Spoiler</summary><div class="spoiler">

### Sur le hub

```bash
sudo wg show
```

Doit afficher le peer, avec un `latest handshake` récent (quelques secondes/minutes) si le peer est bien connecté.

### Test de connectivité

Depuis le VPS produit, vers le hub :

```bash
ping 10.10.0.1
```

Depuis le hub, vers le VPS produit :

```bash
ping 10.10.1.1
```

Si les deux pings fonctionnent, le tunnel privé est opérationnel. Vault (doc 05) pourra désormais écouter uniquement sur `10.10.0.1`, injoignable depuis l'IP publique.

</div></details>

## Ajouter un nouveau VPS produit plus tard

Pour chaque nouveau SaaS ou nouveau serveur, répéter la section "Ajout d'un premier VPS produit" en :

1. Choisissant la prochaine adresse libre selon le schéma d'adressage (`10.10.2.1` pour un 2ème SaaS, `10.10.1.2` pour un 2ème serveur du 1er SaaS, etc.)
2. Générant une nouvelle paire de clefs propre à ce serveur (ne jamais réutiliser une clef d'un autre peer)
3. Ajoutant son bloc `[Peer]` sur le hub, avec son `AllowedIPs` en `/32` dédié
4. Ajoutant sa règle UFW dédiée sur le hub (liste blanche par IP publique)

## Auteur

[<img src="https://github.com/RogerBytes.png" width="40" height="40" style="border-radius:50%;" alt="RogerBytes' avatar">](https://github.com/RogerBytes)
[**RogerBytes (Harry Richmond)**](https://github.com/RogerBytes)

<span hidden>
<details><summary></summary>
<style>.spoiler{border-left:4px solid #1abc9c;border-bottom-left-radius:3px;padding-left:10px;padding-top:15px;margin-top:-10px;margin-bottom:15px}.button{cursor:pointer;padding:5px 10px;background-color:#3498db;color:white;border-radius:3px;margin-bottom:5px;display:inline-block;transition:background-color 0.2s}.button:hover{background-color:#217dbb}details[open] .button{background-color:#1abc9c}</style>
</details></span>

<p align="right"><a href="#">🔝 Retour en haut</a></p>
