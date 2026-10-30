# Projet Fil Rouge : Audit de Sécurité - Plateforme "Code un max"

Ce dépôt regroupe l'ensemble des rapports d'audit, scripts, configurations et analyses réalisés dans le cadre du projet fil rouge de cybersécurité. L'objectif est d'auditer, d'exploiter et de sécuriser une infrastructure web vulnérable au sein d'un environnement de laboratoire contrôlé.

---

## Architecture du Laboratoire (Docker)

Le laboratoire repose sur un réseau virtuel de type bridge (`cyberlab-net` sur le sous-réseau `10.40.0.0/16`) interconnectant deux conteneurs principaux :
* **La Cible (`dvwa-cible`)** : `10.40.0.10` — Héberge l'application web vulnérable (DVWA / stack Apache-PHP).
* **L'Attaquant (`attaquant`)** : `10.40.0.20` — Poste de test sous Debian 12 équipé des outils offensifs et d'analyse.

---

## Sommaire des Travaux et Rapports d'Audit

Le projet est divisé en plusieurs exercices progressifs, chacun documenté dans son rapport dédié :

### 1. Fondamentaux et Environnement (`rapport-audit-01.md`)
* Application de la **Triade CIA** (Confidentialité, Intégrité, Disponibilité).
* Définitions des concepts clés : Menace, Vulnérabilité, Risque et Exploit.
* Configuration et validation de la stack **Docker Compose** et connectivité initiale (`ping`, `curl`).

### 2. Gouvernance et Périmètre (`rapport-audit-02.md`)
* Définition du périmètre d'audit et des rôles impliqués (Red Team, Blue Team, SOC, RSSI, Forensic).
* Mise en place de la **Défense en profondeur** par couches (Réseau, Hôte, Application, Données, Détection).
* Formalisation de la matrice de responsabilité.

### 3. Reconnaissance et Cartographie (`rapport-audit-03.md`)
* Scans de ports et détection de services avec **Nmap** (`-p-`, `-sV`).
* Fingerprinting des en-têtes HTTP et analyse des cookies de session (`PHPSESSID`).
* Capture et analyse de trafic réseau (`tshark`/Wireshark) et gestion des CVE (notion de rétroportage / *backporting*).

### 4. Analyse de Malwares et IoC (`rapport-audit-04.md`)
* Création et analyse d'un faux échantillon de malware inoffensif.
* Calcul d'empreintes **SHA-256** et extraction d'indicateurs de compromission (**IoC**).
* Simulation de contact C2 (Command & Control), test du fichier universel **EICAR** et règles de sauvegarde (3-2-1-1-0).

### 5. Cryptanalyse et Mots de Passe (`rapport-audit-05.md`)
* Cassage d'empreintes **MD5** non salées par dictionnaire avec **Hashcat**.
* Cassage d'empreintes **bcrypt** salées avec **John the Ripper**.
* Recommandations de durcissement : hachage lent, complexité, rate limiting, verrouillage et MFA.

### 6. Injection SQL - SQLi (`rapport-audit-06.md`)
* Exploitation manuelle d'une injection SQL sur DVWA (conditions booléennes et clauses `UNION`).
* Automatisation de l'exfiltration de la table `users` à l'aide de **sqlmap**.
* Comparaison de code et remédiation via l'utilisation de requêtes préparées (PDO) et d'ORM.

### 7. Vulnérabilités XSS (Cross-Site Scripting) (`rapport-audit-07.md`)
* Exploitation des trois familles de XSS : **Réfléchie (`xss_r`)**, **Stockée (`xss_s`)** et **DOM-based (`xss_d`)**.
* Démonstration d'un scénario de vol de session (*Session Hijacking*) par exfiltration du `PHPSESSID` vers un serveur d'écoute HTTP.
* Mise en place de remédiations (échappement contextuel, attribut `HttpOnly`) et configuration d'une **Content Security Policy (CSP)** restrictive (`script-src 'self'`).

### 8. Phishing et Ingénierie Sociale (`rapport-audit-08.md`)
* Analyse d'une campagne de **spear phishing** ciblée (marqueurs de personnalisation, urgence psychologique).
* Classification des techniques d'empoisonnement d'URL (sous-domaines trompeurs, leurre par arobase `@`, homographie **Punycode** / `xn--`).
* Analyse du risque de menace intérieure (*Insider Threat* : accidentel vs malveillant) et procédure de signalement d'un e-mail suspect.

### 9. Attaques Réseau : MITM & DNS Spoofing (`rapport-audit-09.md`)
* Positionnement en Homme du Milieu (MITM) par empoisonnement ARP bidirectionnel (`arpspoof`).
* Détournement de résolution de noms (`dnsspoof`).
* Interception, capture (`mitm.pcap`) et lecture de trafic HTTP en clair avec `tshark`.
* Documentation des protections indispensables : **TLS**, **HSTS** et **DNSSEC**.