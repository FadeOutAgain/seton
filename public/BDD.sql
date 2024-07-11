
/* 
*           Benjamin MOREAU - Script SQL
*	           
*           J'ai pris le parti de le rédiger sans l'interpréter dans SQLite pour conserver du temps sur le partiel "Web & Mobile"
*           Il y a toutes les chances pour que le code ne soit pas fonctionnel.
*/


-- Purge des tables lorsqu'on rejoue le script dans SQLite pour test
 
    DROP TABLE IF EXISTS Board;
    DROP TABLE IF EXISTS Note;
    DROP TABLE IF EXISTS Label;
    DROP TABLE IF EXISTS Etiqueter;
    DROP TABLE IF EXISTS Users;
    
-- Création des tables

    CREATE TABLE Board (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nom VARCHAR(255)
    );

    CREATE TABLE Note (  
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title VARCHAR(255) NULL,
        content BLOB NULL,
        tag VARCHAR(255) NULL,
        dateCreated TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        dateUpdated TIMESTAMP NULL,
        board INTEGER NULL,

        FOREIGN KEY (board_id) REFERENCES Board(id)

    );

-- Insertion de données dans Board et Note

    INSERT INTO Board (nom) VALUES ('Affichage 1');
    INSERT INTO Board (nom) VALUES ('Affichage 2');
    INSERT INTO Board (nom) VALUES ('Affichage 3');

    SELECT * FROM Board;

    INSERT INTO Note (title, content, tag, dateCreated, dateUpdated) VALUES ('Note A','Ceci est ma note A', '', '2024-07-10','2024-07-11');
    INSERT INTO Note (title, content, tag, dateCreated, dateUpdated) VALUES ('Note B','Ceci est ma note B', 'Tag1', '2024-07-10','2024-07-11');
    INSERT INTO Note (title, content, tag, dateCreated, dateUpdated) VALUES ('Note C','Ceci est ma note C', 'Tag2', '2024-07-10','2024-07-11');

    SELECT * FROM Note;

-- Extension des données

-- 1) Création des tables 

    CREATE TABLE Label (
        id INTEGER PRIMARY KEY AUTOINCREMENT
        nom_etiquette VARCHAR(255)
    );

    CREATE TABLE Etiqueter (
        note_id INTEGER NOT NULL,
        label_id INTEGER NOT NULL,
        FOREIGN KEY (note_id) REFERENCES Note(id),
        FOREIGN KEY (label_id) REFERENCES Label(id)
    );

-- 2) Récupération des différentes valeurs de label existantes et insertion dans la table Label

    INSERT INTO Label (nom_etiquette) SELECT DISTINCT tag FROM Note WHERE tag NOT NULL;

-- 3) Alimentation de la table étiqueter avec des Label 

    INSERT INTO Etiqueter (note_id, label_id) SELECT note.id, label.id FROM note,label WHERE note.tag = label.nom_etiquette;

-- 4) Suppression de la colone tag de la table Note

    ALTER TABLE Note
    DROP COLUMN tag;


-- Gestion des utilisateurs

    -- 1) Ajout d'une table User

    CREATE TABLE User (
        login VARCHAR(255) PRIMARY KEY,
        nom VARCHAR(255) NOT NULL,
        prenom VARCHAR(255) NOT NULL,
        adresse VARCHAR(255) NULL,
        email VARCHAR(255) NULL,
        hash  VARCHAR(255) NULL,
        statut VARCHAR(255) NOT NULL,
        CHECK (statut IN "en attente", "actif", "RGPD"),    -- de mémoire, nous n'avions pas réussi à implémenter des
                                                            -- contraintes de ce type en SQLite sur la congélation des entrepôts.
        CHECK (   email LIKE '%_@_%._%' AND
            LENGTH(email) - LENGTH(REPLACE(email, '@', '')) = 1 AND
            SUBSTR(LOWER(email), 1, INSTR(email, '.') - 1) NOT GLOB '*[^@0-9a-z]*' AND
            SUBSTR(LOWER(email), INSTR(email, '.') + 1) NOT GLOB '*[^a-z]*'
        )   -- Le code du CHECK n'est pas de moi, je ne l'ai absolument pas testé, 
            -- mais c'est pour illustrer l'implémentation d'une contrainte de format.
    );


    -- 2) Purge des données personnelles lors du passage du statut à "RGPD"

    CREATE TRIGGER IF NOT EXISTS trigger_rgpd 
    AFTER UPDATE
        ON Users
        FOR EACH ROW
        WHEN NEW.Statut = "RGPD"
    BEGIN
        UPDATE users
        SET adresse = NULL,
            email = NULL
        WHERE login = NEW.login;
    END;


    -- 3) Rattachement  des Notes, des Boards, et des Etiquettes à un user :

    ALTER TABLE Note
        ADD FOREIGN KEY user_login
        REFERENCES User (login);

    ALTER TABLE Board
        ADD FOREIGN KEY user_login
        REFERENCES User (login);

    ALTER TABLE Label
        ADD FOREIGN KEY user_login
        REFERENCES User (login);

    -- À ce stade, la contrainte "les éléments sont * FORCÉMENT * rattachés à un utilisateur"
    -- n'est pas respectée car les enregistrements ne comportaient pas cette information.



-- Gestion des listes

    -- Il ne me paraît pas pertinent de modéliser la structure de listes décrite dans la base de données.
    -- Dans une optique d'efficience, je propose
    --   - d'ajouter un champ "Liste" à la table Note qui contiendra la valeur "Liste"
    --   - d'utiliser le champ "content" pour stocker la liste et ses états cochés au format JSON
    --   - l'application lira / enregistrera les informations dans une structure HTML differente, selon que la note est une liste ou non.

    -- Je comprends de la question vise à nous évaluer sur la notion d'héritage chère au professeur.
    -- Je me permets de décliner trois propositions de réponse :

    -- Version "Single Table" :

        ALTER TABLE Note
        ADD liste VARCHAR(5) NULL;

    -- Version "Multiple Concrete"

        CREATE TABLE NoteListe (

        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title VARCHAR(255) NULL,
        content BLOB NULL,
        tag VARCHAR(255) NULL,
        dateCreated TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        dateUpdated TIMESTAMP NULL,
        board INTEGER NULL,

        FOREIGN KEY (board_id) REFERENCES Board(id)

    );

    -- Version "Multiple CLASS"

        CREATE TABLE NoteListeClasse (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            id_note INTEGER NOT NULL,
            format_list BLOB, 
            FOREIGN KEY (id_note) REFERENCES Note(id)
        );

    -- Je pense qu'à l'usage, la première version sera *** nettement *** plus simple à gérer, 
    -- en n'introduisant pas de redondance (Multiple Concrete)
    -- en ne nécessitant pas de gestion des jointures et des correspondances (Muliple Class)