# 📌 CLI Task Manager (Pure Dart)

[![Dart SDK](https://img.shields.io/badge/Dart-3.0%2B-0175C2?logo=dart)](https://dart.dev)
[![Tests](https://img.shields.io/badge/Tests-27%20passed-success)](https://dart.dev)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

Application en ligne de commande (CLI) de gestion de tâches développée en **Dart pur (sans Flutter)**. L'application respecte les principes de la programmation orientée objet (POO) et de l'architecture propre (Clean Architecture) découplée.

---

## 🎯 Conformité aux Consignes de Certification (100 pts)

| Exigence du sujet | Implémentation dans le code | Statut |
| :--- | :--- | :---: |
| **Pure Dart (no Flutter)** | `pubspec.yaml` utilise le SDK Dart pur sans dépendance Flutter | ✅ |
| **Ajouter une tâche** (titre, priorité: low/medium/high, date limite optionnelle) | `Menu._addStandardTask()` & `Menu._addUrgentTask()` dans [lib/cli/menu.dart](file:///home/sharone/cli_task_manager/lib/cli/menu.dart) | ✅ |
| **Lister les tâches** (tri par priorité ou par date) | `TaskService.getAllTasksSortedByPriority()` et `getAllTasksSortedByDeadline()` dans [lib/services/task_service.dart](file:///home/sharone/cli_task_manager/lib/services/task_service.dart) | ✅ |
| **Marquer une tâche comme terminée** | `TaskService.markTaskAsDone()` & `toggleTaskStatus()` dans [lib/services/task_service.dart](file:///home/sharone/cli_task_manager/lib/services/task_service.dart) | ✅ |
| **Supprimer une tâche** | `TaskService.deleteTask()` dans [lib/services/task_service.dart](file:///home/sharone/cli_task_manager/lib/services/task_service.dart) | ✅ |
| **Persistance JSON locale** | `JsonTaskRepository` avec `dart:convert` et `dart:io` dans [lib/repositories/json_task_repository.dart](file:///home/sharone/cli_task_manager/lib/repositories/json_task_repository.dart) | ✅ |
| **Classes abstraites & Héritage** | Classe abstraite `Task` héritée par `StandardTask` et `UrgentTask` dans [lib/models/](file:///home/sharone/cli_task_manager/lib/models/) | ✅ |
| **Implémentation d'une interface** | `abstract interface class Repository<T>` implémentée par `JsonTaskRepository` | ✅ |
| **Utilisation des Génériques** | `Repository<T>` générique manipulant la donnée typée `Task` | ✅ |
| **Gestion des erreurs avec exceptions sur-mesure** | `TaskManagerException`, `TaskNotFoundException`, `InvalidTaskException`, `StorageException` | ✅ |
| **Au moins 5 tests unitaires** | 27 tests unitaires avec le package `test` dans le dossier [test/](file:///home/sharone/cli_task_manager/test/) | ✅ |

---

## 🏗️ Architecture du Projet

```text
cli_task_manager/
├── bin/
│   └── main.dart                     # Point d'entrée de l'application CLI
├── data/
│   └── tasks.json                    # Stockage local JSON des tâches (auto-créé)
├── lib/
│   ├── cli/
│   │   └── menu.dart                 # Interface CLI interactive et gestion des menus
│   ├── exceptions/
│   │   └── task_exceptions.dart      # Hiérarchie des exceptions personnalisées
│   ├── models/
│   │   ├── priority.dart             # Enum des priorités (low, medium, high)
│   │   ├── task.dart                 # Classe de base abstraite Task + factory JSON
│   │   ├── standard_task.dart        # Classe fille StandardTask
│   │   └── urgent_task.dart          # Classe fille UrgentTask (haute priorité auto)
│   ├── repositories/
│   │   ├── repository.dart           # Interface générique Repository<T>
│   │   └── json_task_repository.dart # Implémentation du repository JSON
│   └── services/
│       └── task_service.dart         # Logique métier, tri, filtres et statistiques
└── test/
    ├── exceptions_test.dart          # Tests des exceptions sur-mesure
    ├── json_task_repository_test.dart # Tests de persistance JSON
    ├── models_test.dart              # Tests des modèles et du polymorphisme
    └── task_service_test.dart        # Tests des méthodes métier de TaskService
```

---

## 🚀 Démarrage Rapide

### Prérequis
- [Dart SDK](https://dart.dev/get-dart) version `3.0.0` ou supérieure.

### 1. Installation
Cloner le dépôt et accéder au répertoire du projet :
```bash
git clone https://github.com/<votre-username>/cli_task_manager.git
cd cli_task_manager
```

Récupérer les dépendances :
```bash
dart pub get
```

### 2. Exécution de l'application CLI
Lancer l'application via le point d'entrée principal :
```bash
dart run bin/main.dart
```

Un menu interactif s'affiche dans votre terminal :
```text
=========================================
      📌 GESTIONNAIRE DE TÂCHES CLI      
=========================================
1. Voir toutes les tâches
2. Ajouter une tâche standard
3. Ajouter une tâche urgente ⚡
4. Marquer / Démarquer une tâche (Terminée)
5. Supprimer une tâche
6. Statistiques & Filtres
7. Quitter
-----------------------------------------
```

---

## 🧪 Exécution des Tests Unitaires

Le projet contient **27 tests unitaires** couvrant l'ensemble des couches (Modèles, Repository JSON, Service Métier et Exceptions).

Pour exécuter la suite complète de tests unitaires :
```bash
dart test
```

### Résultat attendu :
```text
00:02 +27: All tests passed!
```

---

## 💡 Choix Techniques & Polymorphisme

1. **Polymorphisme OOP** :
   - `Task` est une classe abstraite qui définit les propriétés communes (`id`, `title`, `priority`, `deadline`, `isDone`) et les méthodes virtuelles (`typeName`, `icon`, `toJson`).
   - `StandardTask` permet d'attribuer une priorité personnalisée (`low`, `medium`, `high`).
   - `UrgentTask` hérite de `Task` et définit automatiquement la priorité à `Priority.high`.

2. **Pattern Repository & Génériques** :
   - L'interface générique `Repository<T>` découple la couche service de la couche de stockage.
   - `JsonTaskRepository` implémente `Repository<Task>` et gère la lecture/écriture asynchrone sécurisée dans `data/tasks.json`.

3. **Exceptions Personnalisées** :
   - Toutes les exceptions spécifiques dérivent de la classe de base `TaskManagerException` (`TaskNotFoundException`, `InvalidTaskException`, `StorageException`), facilitant leur capture et affichage propre dans l'interface CLI.
