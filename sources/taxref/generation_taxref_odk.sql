/* Animalia */
WITH total AS (
  SELECT
    rang,
    nom_complet,
    CASE
      WHEN cd_nom = cd_ref THEN Concat (
        nom_complet,
        ' ',
        '<b><span style="color:#02138e">(nom valide)</span></b>'
      )
      ELSE Concat(
        nom_complet,
        ' ',
        '<b><span style="color:red"> (syn. de ',
        nom_valide,
        ')',
        '</span></b>'
      )
    END AS lb_nom_key,
    cd_nom :: text AS cd_nom_key,
    nom_complet AS lb_cd_nom_key,
    regne,
    group2_inpn AS groupe,
    group1_inpn,
    fr,
    LOWER(
      CASE
        WHEN (
          lb_nom ilike '% f. %'
          OR lb_nom ilike '%(%'
          OR lb_nom ilike '% x %'
          OR lb_nom ilike '%var.%'
        ) THEN NULL :: text
        ELSE trim(
          CONCAT(LEFT(split_part(lb_nom, ' ', 1), 3),' ',LEFT(split_part(lb_nom, ' ', 2), 3),' ',LEFT(split_part(lb_nom, ' ', 3), 3))
        )
      END
    ) AS code_espece_key
  FROM
    inpn.taxref_16 taxref
  UNION
  SELECT
    rang,
    nom_complet,
    CASE
      WHEN nom_vern IN (
        SELECT nom_vern
        FROM inpn.taxref_16 taxref
        WHERE rang = 'ES'
        GROUP BY nom_vern
        HAVING count (DISTINCT cd_ref) > 1
      ) 
      THEN CONCAT(nom_vern,' ','<b><span style="color:#ff7e06">(',nom_complet,')</span></b>')
      ELSE CONCAT(nom_vern,' -> ',nom_complet,' ','<b><span style="color:#02138e">(nom valide)</span></b>')
    END AS lb_nom_key,
    cd_nom :: text AS cd_nom_key,
    nom_complet AS lb_cd_nom_key,
    regne,
    group2_inpn AS groupe,
    group1_inpn,
    fr,
    LOWER(
      CASE
        WHEN (
          lb_nom ilike '% f. %'
          OR lb_nom ilike '%(%'
          OR lb_nom ilike '% x %'
          OR lb_nom ilike '%var.%'
        ) THEN NULL :: text
        ELSE trim(
          CONCAT(
            LEFT(split_part(lb_nom, ' ', 1), 3),
            ' ',
            LEFT(split_part(lb_nom, ' ', 2), 3),
            ' ',
            LEFT(split_part(lb_nom, ' ', 3), 3)
          )
        )
      END
    ) AS code_espece_key
  FROM
    inpn.taxref_16 taxref
  WHERE
    cd_nom = cd_ref
    AND nom_vern IS NOT NULL
    AND rang = 'ES'
)
SELECT
  lb_nom_key,
  cd_nom_key,
  lb_cd_nom_key,
  regne AS regne_key,
  groupe,
  group1_inpn,
  code_espece_key,
  16 AS version_taxref,
  rank() OVER(
    ORDER BY
      CASE
        WHEN rang = 'GN' THEN 1
        ELSE 2
      END,
      CASE
        WHEN lb_nom_key ilike '%nom valide%' THEN 3
        ELSE 4
      END,
      lb_nom_key
  ) AS sortby
FROM
  total
WHERE regne IN ('Animalia') AND (fr IN ('P','E','S','C','I','J','M','B')
  AND (
    groupe NOT IN ('Diatomées', 'Scléractiniaires', 'Pycnogonides', 'Octocoralliaires', 'Ochrophyta', 'Rhodophytes', 'Némertes', 'Nématodes', 'Hydrozoaires', 'Ascidies', 'Annélides', 'Acanthocéphales')
    OR groupe IS NULL
  )
  AND (
    group1_inpn NOT IN ('Bryozoaires', 'Cnidaires', 'Cryptophytes', 'Cténaires', 'Cyanobactéries', 'Echinodermes', 'Foraminifères', 'Gastrotriches', 'Onychophores', 'Porifères', 'Rotifères', 'Siponcles', 'Tardigrades', 'Vers', 'Protéobactéries')
    OR group1_inpn IS NULL
  )
ORDER BY
  sortby;

/* Plantae */

WITH total AS (
  SELECT
    rang,
    nom_complet,
    CASE
      WHEN cd_nom = cd_ref THEN CONCAT (nom_complet,' ','<b><span style="color:#02138e">(nom valide)</span></b>'
      )
      ELSE CONCAT(nom_complet,' ','<b><span style="color:red"> (syn. de ',nom_valide,')','</span></b>'
      )
    END AS lb_nom_key,
    cd_nom AS cd_nom_key,
    nom_complet AS lb_cd_nom_key,
    regne,
    group2_inpn AS groupe,
    group1_inpn,
    fr,
    LOWER(
      CASE
        WHEN (
          lb_nom ILIKE '% f. %'
          OR lb_nom ILIKE '%(%'
          OR lb_nom ILIKE '% x %'
          OR lb_nom ILIKE '%var.%'
        ) THEN NULL :: text
        ELSE trim(
          CONCAT(left(split_part(replace(lb_nom, ' subsp.', ''), ' ', 1), 3),' ',left(split_part(replace(lb_nom, ' subsp.', ''), ' ', 2), 3),' ',left(split_part(replace(lb_nom, ' subsp.', ''), ' ', 3), 3)
)
        )
      END
    ) AS code_espece_key
  FROM
    inpn.taxref_16 taxref
  WHERE regne IN ('Plantae') 
  UNION
  SELECT rang, nom_complet,
    CASE
      WHEN nom_vern in (
        SELECT nom_vern
        FROM inpn.taxref
        WHERE rang = 'ES'
        group by nom_vern
        having count (distinct cd_ref) > 1
      ) THEN CONCAT(nom_vern,' ','<b><span style="color:#ff7e06">(',lb_nom,')</span></b>')
      ELSE CONCAT(nom_vern,' -> ',nom_complet,' ','<b><span style="color:#02138e">(nom valide)</span></b>')
    END AS lb_nom_key,
    cd_nom AS cd_nom_key,
    CONCAT_ws('!', lb_nom, cd_nom) AS lb_cd_nom_key,
    regne,
    group2_inpn AS groupe,
    group1_inpn,
    fr,
    LOWER(
      CASE
        WHEN (
          lb_nom ILIKE '% f. %'
          OR lb_nom ILIKE '%(%'
          OR lb_nom ILIKE '% x %'
          OR lb_nom ILIKE '%var.%'
        ) 
		THEN NULL :: text
        ELSE trim(CONCAT(left(split_part(replace(lb_nom, ' subsp.', ''), ' ', 1), 3),' ',left(split_part(replace(lb_nom, ' subsp.', ''), ' ', 2), 3),' ',left(split_part(replace(lb_nom, ' subsp.', ''), ' ', 3), 3)))
      END
    ) AS code_espece_key
  FROM
    inpn.taxref_16 taxref
  WHERE cd_nom = cd_ref AND regne IN ('Plantae') AND nom_vern IS NOT NULL AND rang = 'ES'
)
SELECT
  DISTINCT lb_nom_key,
  cd_nom_key,
  lb_cd_nom_key,
  regne AS regne_key,
  groupe,
  group1_inpn,
  code_espece_key,
  16 AS version_taxref,
  dense_rank() Over(
    ORDER BY
      CASE
        WHEN rang = 'GN' THEN 1
        ELSE 2
      END,
      CASE
        WHEN lb_nom_key ILIKE '%nom valide%' THEN 3
        ELSE 4
      END,
      lb_nom_key
  ) AS sortby
FROM
  total
WHERE regne IN ('Plantae') AND fr IN ('P', 'E', 'S', 'C', 'I', 'J', 'M', 'B', 'D')
ORDER BY
  sortby

/* Fungi */

WITH total AS (
  SELECT
    rang,
    nom_complet,
    CASE
      WHEN cd_nom = cd_ref 
		THEN CONCAT (nom_complet,' ','<b><span style="color:#02138e">(nom valide)</span></b>')
      	ELSE CONCAT(nom_complet,' ','<b><span style="color:red"> (syn. de ',nom_valide,')','</span></b>')
    END AS lb_nom_key,
    cd_nom AS cd_nom_key,
    nom_complet AS lb_cd_nom_key,
    regne,
    group2_inpn AS groupe,
    group1_inpn,
    fr,
    LOWER(
      CASE
        WHEN (
          lb_nom ILIKE '% f. %'
          OR lb_nom ILIKE '%(%'
          OR lb_nom ILIKE '% x %'
          OR lb_nom ILIKE '%var.%'
        ) THEN NULL :: text
        ELSE trim(CONCAT(left(split_part(lb_nom, ' ', 1), 3),' ',left(split_part(lb_nom, ' ', 2), 3),' ',left(split_part(lb_nom, ' ', 3), 3)))
      END
    ) AS code_espece_key
  FROM
    inpn.taxref_16 taxref
  UNION
  SELECT
    rang,
    nom_complet,
    CASE
      WHEN nom_vern in (
        SELECT nom_vern
        FROM inpn.taxref_16 taxref
        WHERE rang = 'ES'
        group by nom_vern
        having count (distinct cd_ref) > 1
      ) THEN CONCAT(nom_vern,' ','<b><span style="color:#ff7e06">(',nom_complet,')</span></b>')
      ELSE CONCAT(nom_vern,' -> ',nom_complet,' ','<b><span style="color:#02138e">(nom valide)</span></b>')
    END AS lb_nom_key,
    cd_nom AS cd_nom_key,
    nom_complet AS lb_cd_nom_key,
    regne,
    group2_inpn AS groupe,
    group1_inpn,
    fr,
    LOWER(
      CASE
        WHEN (
          lb_nom ILIKE '% f. %'
          OR lb_nom ILIKE '%(%'
          OR lb_nom ILIKE '% x %'
          OR lb_nom ILIKE '%var.%'
        ) 
		THEN NULL :: text
        ELSE trim(CONCAT(left(split_part(lb_nom, ' ', 1), 3),' ',left(split_part(lb_nom, ' ', 2), 3),' ',left(split_part(lb_nom, ' ', 3), 3)))
      END
    ) AS code_espece_key
  FROM
    inpn.taxref_16 taxref
  WHERE
    cd_nom = cd_ref
    AND nom_vern IS NOT NULL
    AND rang = 'ES'
)
SELECT 
  lb_nom_key,
  cd_nom_key,
  lb_cd_nom_key,
  regne AS regne_key,
  groupe,
  group1_inpn,
  code_espece_key,
  16 AS version_taxref,
  rank() Over(
    ORDER BY
      CASE
        WHEN rang = 'GN' THEN 1
        ELSE 2
      END,
      CASE
        WHEN lb_nom_key ILIKE '%nom valide%' THEN 3
        ELSE 4
      END,
      lb_nom_key
  ) AS sortby
FROM
  total
WHERE regne IN ('Fungi') AND fr IN ('P', 'E', 'S', 'C', 'I', 'J', 'M', 'B', 'D')
ORDER BY sortby;



