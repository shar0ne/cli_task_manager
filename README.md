#  Dart CLI Task Manager

Un gestionnaire de tâches interactif en ligne de commande (CLI) développé en **Dart**. L'application applique les principes d'architecture propre (Clean Architecture) et de programmation orientée objet (POO) pour gérer des tâches standards et urgentes avec persistance dans un fichier JSON local.

---

##  Architecture du Projet

Le projet suit une **Layered Architecture** découplée :

```text
cli_task_manager/
├── bin/
│   └── main.dart                   # Point d'entrée principal
├── data/
│   └── tasks.json                  # Stockage JSON local (ignoré par git)
├── lib/
│   ├── cli/
│   │   └── menu.dart               # Interface utilisateur CLI & menu interactif
│   ├── models/
│   │   ├── priority.dart           # Enum des priorités (low, medium, high)
│   │   ├── task.dart               # Classe de base abstraite
│   │   ├── standard_task.dart      # Modèle de tâche standard
│   │   └── urgent_task.dart        # Modèle de tâche urgente (priorité HIGH par défaut)
│   ├── repositories/
│   │   ├── repository.dart         # Interface générique Repository<T>
│   │   └── json_task_repository.dart # Implémentation de la persistance JSON
│   └── services/
│       └── task_service.dart       # Logique métier, filtres et statistiques
└── test/
    └── task_service_test.dart      # Tests unitaires du service métier
Fonctionnalités
Gestion polymorphe : Prise en charge des tâches standards et urgentes.

Design Pattern Repository : Interface abstraite Repository<T> découplant l'accès aux données.

Persistance JSON : Sauvegarde et lecture asynchrone dans un fichier local (dart:io & dart:convert).

Couche Service Métier : Calcul du taux d'avancement (%), filtrage par priorité, suivi des tâches en retard ou en attente.

Interface CLI dynamique : Menu interactif géré via stdin et stdout.

📋 Prérequis
Dart SDK (v3.0.0 ou plus récent) installé sur votre machine.

💻 Exécution de l'Application
Cloner le dépôt :

Bash
git clone [https://github.com/](https://github.com/)<votre-utilisateur>/cli_task_manager.git
cd cli_task_manager
Récupérer les dépendances :

Bash
dart pub get
Lancer l'application :

Bash
dart run bin/main.dart
🧪 Exécution des Tests Unitaires
Pour lancer l'ensemble des tests unitaires du projet :

Bash
dart test


<FollowUp label="Veux-tu qu'on écrive les tests unitaires (test/) pour valider l'exécution de 'dart test' ?" query="Écrivons les tests unitaires dans le dossier test/ pour exécuter dart test."/>
