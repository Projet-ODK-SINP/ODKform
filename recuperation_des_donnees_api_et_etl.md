# Récupération des données collectées dans des fichiers .csv pour intégration dans une base de données PostgreSQL/PostGIS via l'ETL FME (exemple pour Kollect)

Utilisation de l' [API ODK Central](https://odkcentral.docs.apiary.io) et de l'ETL FME Form/Flow

### 1/ Transformation des données nouvellement intégrées dans ODK Central vers des fichiers .csv et des médias attachés (photos au format .jpg) en utilisant l’API d’ODK Central 

On ne récupère pas les formulaires dont l’état de la soumission est à “Approuvée” 

```js 
axios.get(`${process.env.SERVER_URL}v1/projects/${project.id}/forms/${form.xmlFormId}/submissions.csv.zip?$filter=_ 
_system/reviewState ne 'approved'`,  
                       {  
                           responseType: 'arraybuffer',  
                           responseEncoding: 'binary',  
                           headers: {  
                               'Authorization': `Basic ${process.env.ADMIN_TOKEN}`,  
                               'Content-Type': 'application/octet-stream',  
                               responseType: 'arraybuffer',  
                               responseEncoding: 'binary'  
                           }  
                       }).then((zip) => {  
                       const  
                           //rootpath = './submissions/', // For local dev  
                           rootpath = `${process.env.DATAURL}`,  
                           dirname = project.id,  
                           filename = form.xmlFormId;  
                       fs.mkdirSync(rootpath + dirname, { recursive: true });  
                       fs.writeFileSync(rootpath + dirname + '/' + filename + '.zip', zip.data);  
                       fs.createReadStream(rootpath + dirname + '/' + filename + '.zip')  
                           .pipe(unzipper.Extract({path: rootpath + dirname + '/' + filename}));  
                   }); 


```
### 2/ Mise en place du cron pour réaliser cette opération toutes les heures  

```js
0 * * * * /usr/sbin/runuser fmeserver -c '/usr/bin/node /home/fmeserver/API-ODK/index.js --exportAll'
```
-----
### 3/ Lancement du workflow FME pour intégrer les observations dans Kollect 

<br>

Ce workflow permet de : 

* Lire les différents .csv précédemment créés via l’API et insérer les données associées dans les différentes tables de la base de données de Kollect 

* Récupérer les photos attachées aux observations et les redimensionner au format web (on utilise le transformer FME “FeatureReader” et “RasterResampler” puis “FeatureWriter”) 

* Passer l’état de la soumission à “Approuvée” dans ODK Central quand toutes les observations d’un formulaire ont été intégré


### 4/ Lancement du workflow FME pour intégrer les photos redimensionnées sur le serveur de Kollect 

Ce workflow permet de : 

* Envoyer les photos redimensionnées précédemment vers le serveur de Kollect en SFTP 

<br>

----

<br>

L’utilisation de FME Flow (anciennement FME Server) permet de : 

* Programmer toutes les heures le lancement du workflow décrit à l’étape 3 après le lancement du cron décrit à l’étape 1 

    Lancer automatiquement le workflow décrit à l’étape 4 via une “Automation” : une fois que le workflow d’intégration des données a été terminé avec succès, cela permet de lancer automatiquement la procédure de copie des photos en SFTP 

Il est tout à fait possible d’utiliser FME Form (anciennement FME Desktop) sans passer par FME Server pour les intégrations. 










