 ---
# PromethIonDashboard

## __objectif__
- visualiser des statistiques sur les runs promethIon en cours et terminés
   - Qualité des reads
   - Débit
   - Visulation des statistiques par pores de la flowcell
   - Comparaison de runs
- mise à jour de l'interface en temps réel
- outil disponible en standalone
   - utilisable directement depuis le pc de l'utilisateur
   - via un serveur

 ---

## __Données__
Les données sont générées pendant le basecalling.

### Fichier run_infostat.txt
Contient la liste des runs avec des métriques générales. Les statistiques d'un run sont mis à jour au cours du run.

| FLOWCELL | STARTTIME | ENDED | DURATION(mn) | YIELD(b) | #READS | SPEED(b/mn) | QUALITY | N50(b) | AVG(b) | MED(b)
| ----------- | ----------- | ----------- | ----------- | ----------- | ----------- | ----------- | ----------- | ----------- | ----------- | ----------- |
| PAD24850_A | 2019-01-28T10:55:50Z | YES | 3840 | 78656991450 | 8524652 | 362 | 6.34 | 25041 | 9227 | 3753
| PAD22628_A | 2019-01-28T10:56:10Z | YES | 3840 | 62025108575 | 6405705 | 367 | 6.18 | 26063 | 9683 | 3979

### Fichier {run}_globalstat.txt
Statistiques sur le run a des temps régulier. Les stastiques sont calculées sur l'ensemble des données générées depuis le début du run.

| FLOWCELL | DURATION(mn) | YIELD(b) | #READS | SPEED(b/mn) | QUALITY | N50(b) | AVG(b) | MED(b)
| ----------- | ----------- | ----------- | ----------- | ----------- | ----------- | ----------- | ----------- | ----------- |
| PAD58831_A | 10 | 293102483 | 40538 | 366 | 10.15 | 21731 | 7230 | 2026
| PAD58831_A | 20 | 754868184 | 88800 | 370 | 10.30 | 23044 | 8501 | 2566

### Fichier {run}_currentstat.txt
Statistiques sur le run a des temps régulier. Les stastiques sont calculées seulement sur données générées à ce moment.

| FLOWCELL | DURATION(mn) | YIELD(b) | #READS | SPEED(b/mn) | QUALITY | N50(b) | AVG(b) | MED(b)
| ----------- | ----------- | ----------- | ----------- | ----------- | ----------- | ----------- | ----------- | ----------- |
| PAD58831_A | 10 | 293102483 | 40538 | 366 | 10.15 | 21731 | 7230 | 2026
| PAD58831_A | 20 | 461765701 | 48262 | 374 | 10.43 | 23806 | 9568 | 3210

### Fichier sequencing_summary.txt

| filename_fastq | filename_fast5 | read_id | run_id | channel | mux | start_time | duration | num_events | passes_filtering | template_start | num_events_template | template_duration | sequence_length_template | mean_qscore_template | strand_score_template | median_template | mad_template | pore_type | experiment_id | sample_id
| ----------- | ----------- | ----------- | ----------- | ----------- | ----------- | ----------- | ----------- | ----------- | ----------- | ----------- | ----------- | ----------- | ----------- | ----------- | ----------- | ----------- | ----------- | ----------- | ----------- | ----------- |
| PAD57551_727512cc3c434504cb0ce4f5686b2331d3a816e5_0.fastq | PAD57551_727512cc3c434504cb0ce4f5686b2331d3a816e5_0.fast5 | 5d43b378-fc90-42f8-8a40-a96a727e0f3e | 727512cc3c434504cb0ce4f5686b2331d3a816e5 | 220 | 1 | 6.329000 | 1.957000 | 0 | FALSE | 6.329000 | 0 | 1.957000 | 303 | 3.458075 | 0.000000 | 66.524208 | 2.193106 | not_set | prom185 | PAD57551
| PAD57551_727512cc3c434504cb0ce4f5686b2331d3a816e5_0.fastq | PAD57551_727512cc3c434504cb0ce4f5686b2331d3a816e5_0.fast5 | ca048888-fb5d-4d13-936a-98d859f77653 | 727512cc3c434504cb0ce4f5686b2331d3a816e5 | 2622 | 1 | 8.062750 | 0.696750 | 0 | TRUE | 8.119250 | 0 | 0.640250 | 200 | 7.601170 | 0.000000 | 54.827648 | 8.406906 | not_set | prom185 | PAD57551

 ---

## __Techno__
Shiny dashboard pour l'interface web.
ggplot pour générer les graphiques.
plotly pour rendre les graphiques interactifs.
### Dépendences
Uniquement des libraries R:
```{r}
library(ggplot2)
library(plotly)
library(shiny)
library(shinydashboard)
library(data.table)
library(readr)
```

---

## __Interface__

### Page global

Page sur l'ensemble des runs.
- Nombre de runs en cours
- Quantité de bases générées par run
  - si l'utilisateur clique sur un run, la page du run correspondant sera affiché 
- Graphique avec choix des axes (colonnes du fichier run_infostat.txt)

### Page run

Page affichant les statistiques sur un run. 
- Une liste déroulante permet de séléctionner un run, les runs en cours et terminés sont séparés dans cette liste.
 - Un tableau contenant les statistiques du fichier run_infostat.txt

- Deux onglets, un pour les stats cumulées (fichier {run}\_globalstat.txt) et un deuxième pour les stats non cumulées (fichier {run}\_currentstat.txt). Chaque onglet présente les mêmes graphiques avec leurs données respective. Ils sont sous-divisé en 2 onglets:
  - Onglet global, affichant 3 graphiques en bar coloré par la qualité moyenne:
     - durée en fonction du nombre de reads
     - durée en fonction du nombre de bases
     - durée en fonction du débit

  - Onglet channel, 1 graphique affichant l'ensemble des pores colorés en fonction d'une variable. La variable est sélectionnée parmis les colonnes du {run}\_globalstat.txt ou {run}\_currentstat.txt dans une liste déroulante.

### Page comparaison

Une liste déroulant de run à choix multiple. L'ensemble des runs sélectionnés sont affichés dans un graphique: temps en fonction du nombre de bases générées.

---

## __A faire__

- Page Run
    - Abscisse des graphiques: En heures/jours sans dynamic tick ou en minutes avec dynamic tick?
    - graphique channel
        - avoir le fichier sequencing_summary.txt ( voir avec stefan )
        - générer un fichier réduit contenant la moyenne par pore des différents métriques du fichier
        - possible en non cumulé ??
    - graphique qualité en fonction du temps ( en grille car trop de points)
        - par le fichier sequencing_summary.txt
        - générer un fichier réduit contenant pour une plage de qualité et de temps le nombre de read
        - on peut aussi l'avoir avec les longueurs ou d'autres métriques
    - le fichier sequencing_summary.txt est trop gros pour être chargé à chaque fois (2~3Go)
        - genérer des fichiers intermédiaires seulement s'il ils n'existent pas ou si ils ne sont plus à jour.
---

## __Idées__
- Page global
    - Tableau contenant les runs en cours












