# Audit de securite - Plateforme Code un max

## 1. Reconnaissance
#### 1.1 Vérifier que la cible est joignable
```bash
docker exec attaquant ping -c 2 10.40.0.10
```

#### 1.2 Installer les outils (nmap et tshark)
```bash
docker exec attaquant bash -c "apt-get update && apt-get install -y nmap"
docker exec attaquant bash -c "DEBIAN_FRONTEND=noninteractive apt-get install -y tshark"
```
#### 1.3 Cartographier les services exposés
**Objectif** : Scanner l'ensemble des ports pour identifier les version des ports exposés
```bash
docker exec attaquant nmap -p- 10.40.0.10
```
l'option `-p-` permet de scanner l'ensemble de tous les ports plutôt que les 1000 ports les plus utilisés.

![nmap](/Rapports/Screen-02/image-3.png)


```bash
docker exec attaquant nmap -sV -p 80 10.40.0.10
```
* l'option `-sV` permet de détecter les services ainsi que leur version.
* l'option `-p` permet de spécifier un port en particulier, ici le port 80 (HTTP)

![nmap](/Rapports/Screen-02/image-4.png)

#### 1.4 Fingerprinting de l'application web
**Objectif** : Collecter les en-têtes HTTP pour identifier PHP, les cookies de sessions et la redirection vers `login.php`

```bash
docker exec attaquant curl -s -I http://10.40.0.10/
```
![fingerprint](/Rapports/Screen-02/image-5.png)

```bash
docker exec attaquant curl -s -I http://10.40.0.10/login.php
```
![fingerprint](/Rapports/Screen-01/image-6.png)

#### 1.5 Capture et analyse du traffic HTTP
**Objectif** : Enregistrer et analyser le traffic HTTP échangé dans un fichier `.pcap` pour relire la capture du traffic
```bash
docker exec attaquant bash -c "(sleep 2; for i in 1 2 3 4 5 6; do curl -s -o /dev/null http://10.40.0.10/; done) & tshark -i eth0 -f 'host 10.40.0.10 and port 80' -c 10 -a duration:20 -w /tmp/capture-recon.pcap && cp /tmp/capture-recon.pcap /data/"
```

```bash
docker exec attaquant tshark -r /data/capture-recon.pcap -Y http
```

![analyse du traffic](/Rapports/Screen-01/image-7.png)

##### 1.5.1 Analyse avec Wireshark
```bash
docker exec attaquant bash -c "(sleep 2; for i in 1 2 3 4 5 6; do curl -s -o /dev/null -d 'username=admin&password=password' http://10.40.0.10/login.php; done) & tshark -i eth0 -f 'host 10.40.0.10 and port 80' -c 10 -a duration:20 -w /tmp/capture-recon.pcap && cp /tmp/capture-recon.pcap /data/"
```
**Filtre wireshark** : `ip.src==10.40.0.20&&http`
![analyse du traffic](/Rapports/Screen-01/image-9.png)

![analyse du traffic](/Rapports/Screen-01/image-10.png)


#### 1.6 Interception et manipulation de requêtes
**Installation de l'outil BurpSuite**
```bash
docker exec attaquant bash -c "apt-get install -y default-jre && curl -o /tmp/burp.sh 'https://portswigger.net/burp/releases/download?product=community&type=Linux' && chmod +x /tmp/burp.sh"
```

**Forger une requête personnalisée avec `curl`**
```bash
docker exec attaquant curl -s -v -H "User-Agent: AuditCodeMax" http://10.40.0.10/login.php -o /dev/null
```
![requête personnalisée](/Rapports/Screen-01/image-8.png)

#### 1.7 Résultat de la reconnaissance
- Cible : `dvwa-cible` / IP : `10.40.0.10`
- Service exposé : `Apache httpd 2.4.25` / port : `80`
- Application : PHP (`PHPSESSID`) - **PHPSESSID** est un identifiant unique (sous forme de chaîne de caractères obligatoire aléatoire) généré par PHP pour suivre la session d'un visiteur sur l'application web

#### 1.7.1 Liste des CVE pour Apache 2.4.25 (DVWA)

| Identifiant CVE | Sévérité (CVSS) | Type de vulnérabilité | Description & Impact |
| :--- | :--- | :--- | :--- |
| **CVE-2019-0211** | 🔴 **7.2 Élevée** | Élévation de privilèges | Une exécution de code local via un processus enfant (ex: via PHP) permet d'obtenir les privilèges root sur le processus parent. |
| **CVE-2017-7668** | 🟠 **7.5 Moyenne** | Déni de service (DoS) | Des en-têtes HTTP malformés déclenchent une lecture hors limites dans `ap_find_token()`, provoquant le plantage du serveur. |
| **CVE-2017-3167** | 🟠 **7.5 Moyenne** | Contournement d'authentification | Les modules tiers utilisant `ap_get_basic_auth_pw()` peuvent contourner les exigences d'authentification. |
| **CVE-2017-3169** | 🟠 **7.5 Moyenne** | Déréférencement de pointeur NULL | Des modules tiers peuvent déclencher un déréférencement de pointeur NULL dans `mod_ssl`, entraînant un plantage. |
| **CVE-2017-7679** | 🟡 **5.3 Moyenne** | Divulgation d'informations | Une entrée malveillante dans `mod_mime` peut divulguer des données sensibles de la mémoire de pile ou causer un plantage. |

### 1.7.2 Fiabilité du Fingerprinting (curl vs nmap)
- **curl** récupère l'en-tête HTTP explicite (`Server`), qui peut être facilement modifié, masqué ou falsifié par l'administration du serveur.
- **nmap -sV** analyse le comportement réseau et les réponses aux sondes, offrant une détection de version plus robuste, bien qu'elle puisse être influencée par le rétroportage (*backport*) de correctifs de sécurité par la distribution.

### 1.7.3 Le rétroportage (Backporting)
Le rétroportage consiste, pour les mainteneurs d'une distribution comme Debian, à appliquer un correctif de sécurité récent sur une ancienne version d'un logiciel, sans modifier son numéro de version officiel. 

**Impact sur l'audit :** Un scanner de vulnérabilités ou un outil comme `nmap` peut signaler à tort qu'une machine est vulnérable (faux positif) en se fiant uniquement au numéro de version, alors que le correctif a en réalité déjà été appliqué par la distribution.