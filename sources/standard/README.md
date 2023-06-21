# Standard "Occurence de taxons"
Les éléments constitutifs du standard "Occurences de taxon" v 2.0

## Diagramme de classes

https://standards-sinp.mnhn.fr/wp-content/uploads/sites/16/versionhtml/occtax_v2/index.htm

En cours de synthèse dans un tableur

## Nomenclatures

### Récupration des nomenclatures du SINP

```sh
 wget -r -l4 -A.csv https://standards-sinp.mnhn.fr/nomenclature/ -awgetlog
```

### Compilation dans un seul csv

On les complie dans un seul fichier csv en ajoutant en premiere colonne le nom du fichier

```sh
find ./ -type f -exec awk '{print "{};" $0}' {} \; > ../nomenclatures_sinp.csv
```
