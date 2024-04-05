-- DROP 
DROP SEQUENCE seq_pokemon_id ;
DROP SEQUENCE seq_pokedex_id ;
DROP SEQUENCE seq_dresseur_id;

DROP INDEX idx_prenom_dresseur;
DROP INDEX idx_types_pokemon ;
DROP PROCEDURE Decouverte ;
DROP TRIGGER CaptureCond;

DROP VIEW Nbr_Pokemon_Capturer;
DROP VIEW nb_Pokemon ;
DROP VIEW Stats_Pokemon_Capture;
DROP VIEW Information_Dresseur;

DROP PROCEDURE Relacher;
DROP PROCEDURE UpdateNbPokemonCaptureAll ;
DROP PROCEDURE UpdateNbPokemonApercuAll ;

-- Index
CREATE INDEX idx_prenom_dresseur ON Dresseur(prenom);
CREATE INDEX idx_types_pokemon ON Pokemon(type1, type2);

-- View
CREATE VIEW Nbr_Pokemon_Capturer AS
  SELECT idPokedex, Count(numSpecimen) AS nbMemePoke
  FROM Specimen
  GROUP BY idPokedex
;

CREATE VIEW nb_Pokemon AS
  SELECT COUNT(DISTINCT idPokemon) AS nbPoke
  FROM Pokemon
;

CREATE VIEW Stats_Pokemon_Capture AS
  SELECT niveau, vie, taille, poids, idPokemon
  FROM Specimen
;

CREATE VIEW Information_Dresseur AS
	SELECT idDresseur, nom, prenom, adresse
	FROM Dresseur
;
-- Fonction / Procedure


-- Met a jour le nombre de pokemon apercu en fonction des 1 dans la colonne d'un pokedex
CREATE OR REPLACE PROCEDURE UpdateNbPokemonApercuAll (
    p_idPokedex IN NUMBER,
    p_idDresseur IN NUMBER
) IS
BEGIN
    UPDATE Pokedex
    SET nbPokemonApercu = (
        SELECT COUNT(*)
        FROM Pokedex
        WHERE idPokedex = p_idPokedex AND apercu = 1
    )
    WHERE idPokedex = p_idPokedex AND idDresseur = p_idDresseur;
END;
/

-- met a jour le nombre de capturer d'un pokedex en fonction du nombre de specimen
CREATE OR REPLACE PROCEDURE UpdateNbPokemonCaptureAll (
    p_idPokedex IN NUMBER,
    p_idDresseur IN NUMBER
) IS
BEGIN
    UPDATE Pokedex
    SET nbPokemonCapture = (
        SELECT COUNT(numSpecimen)
        FROM Specimen
        WHERE idPokedex = p_idPokedex AND idDresseur = p_idDresseur 
    )
    WHERE idPokedex = p_idPokedex AND idDresseur = p_idDresseur;

END;
/

-- permet de rajouter dans specimen le pokemon capturer ainsi que de le rajouter dans les donnÃ©es du pokedex
CREATE OR REPLACE PROCEDURE Capture (
    p_idPokedex IN NUMBER,
    p_idDresseur IN NUMBER,
    p_idPokemon IN NUMBER
    )
IS
    nbcap NUMBER;
    capturer NUMBER(1);
    apercevoir NUMBER(1);
    pas_apercu EXCEPTION ;
BEGIN
    SELECT capture INTO capturer
    FROM Pokedex
    WHERE Pokedex.idPokemon = p_idPokemon AND Pokedex.idPokedex = p_idPokedex AND Pokedex.idDresseur = p_idDresseur ;
    
    SELECT apercu INTO apercevoir
    FROM Pokedex
    WHERE Pokedex.idPokemon = p_idPokemon AND Pokedex.idPokedex = p_idPokedex AND Pokedex.idDresseur = p_idDresseur ;
    
    SELECT nbPokemonCapture INTO nbcap
    FROM Pokedex
    WHERE Pokedex.idPokemon = p_idPokemon AND Pokedex.idPokedex = p_idPokedex AND Pokedex.idDresseur = p_idDresseur ;   
    -- insert dans specimen le pokemon (probleme avec le trigger a ce moment la)
    INSERT INTO Specimen (numSpecimen, niveau, idPokedex, idPokemon) VALUES (nbcap+1, ROUND(DBMS_RANDOM.value(1, 100),2), p_idPokedex, p_idPokemon);
    
    -- si le pokemon n'a jamais Ã©tÃ© capturÃ©, il est notÃ© capturÃ© dans le pokedex du dresseur
    -- Probleme d'update du capture, ne se met pas a 1 malgré les conditions remplies
    IF capturer = 0 AND apercevoir = 1 THEN
        UPDATE Pokedex SET capture = 1 
        WHERE Pokedex.idPokemon = p_idPokemon AND Pokedex.idPokedex = p_idPokedex AND Pokedex.idDresseur = p_idDresseur ;
    END IF ;
    UpdateNbPokemonCaptureAll(p_idPokedex, p_idDresseur);
END Capture;
/


CREATE OR REPLACE PROCEDURE Decouverte (
    p_idPokedex IN NUMBER,
    p_idDresseur IN NUMBER,
    p_idPokemon IN NUMBER
    )
IS
BEGIN
-- met apercu a 1 etant donnÃ© que le pokemon est dÃ©couvert
    UPDATE Pokedex SET apercu = 1
    WHERE idPokedex = p_idPokedex AND idDresseur = p_idDresseur AND idPokemon = p_idPokemon;
    UpdateNbPokemonApercuAll (p_idPokedex, p_idDresseur);
END Decouverte;
/




-- Fonction qui permet de relacher un pokemon dont le numero du specimen et le pokedex sont donnÃ© en entrÃ©e
CREATE PROCEDURE Relacher(num_spe IN NUMBER, idPokd IN NUMBER) 
IS
id_poke NUMBER;
nbtotal NUMBER;
id_dre NUMBER;
CURSOR reglage_num IS 
            SELECT numSpecimen
            FROM Specimen
            WHERE numSpecimen > num_spe AND idPokedex = idPokd FOR UPDATE;
BEGIN 
    SELECT idPokemon INTO id_poke
    FROM Specimen
    WHERE Specimen.numSpecimen = num_spe AND Specimen.idPokedex = idPokd;
  DELETE FROM Specimen
  WHERE numSpecimen = num_spe AND Specimen.idPokedex = idPokd;

  IF SQL%FOUND THEN --delete succeeded 
  --permet de voir combien de pokemon reste avec le meme id 
    SELECT count(*) INTO nbtotal
    FROM Specimen 
    WHERE Specimen.idPokedex = idPokd AND Specimen.idPokemon = id_poke;
    -- s'il n'y a plus de pokemon de cet id, il doit etre mis a 0 dans le pokedex
    IF ( nbtotal = 0) THEN	
      UPDATE Pokedex SET capture = 0
      WHERE id_poke = Pokedex.idPokemon AND idPokd = Pokedex.idPokedex ;
    END IF;
   
 -- regle les numero des pokemon suivant de cette table Specimen

    FOR item IN reglage_num 
        LOOP 
    		UPDATE Specimen
   		SET numSpecimen = item.numSpecimen - 1
    		WHERE CURRENT OF reglage_num;
        END LOOP;
  END IF;
-- actualise le nombre de pokemon capturer
  	SELECT idDresseur INTO id_dre
	FROM Pokedex
	WHERE 04 = Pokedex.idPokedex and idPokemon = 01;
	UpdateNbPokemonCaptureAll(idPokd, id_dre);

END;
/
 show err



-- Trigger 
--Trigger sur l'insertion d'une ligne dans Specimen

CREATE OR REPLACE TRIGGER CaptureCond
BEFORE INSERT ON Specimen
FOR EACH ROW
DECLARE 
    p_apercu NUMBER(1);
    nbcap NUMBER;
  pas_apercu EXCEPTION;
  pas_le_bon_num EXCEPTION;
BEGIN	
    SELECT apercu into p_apercu
    FROM Pokedex
    WHERE :NEW.idPokemon = Pokedex.idPokedex AND :NEW.idPokemon = Pokedex.idPokemon; 
    
    SELECT nbPokemonCapture INTO nbcap
    FROM Pokedex
    WHERE :NEW.idPokemon = Pokedex.idPokedex AND :NEW.idPokemon = Pokedex.idPokemon; 
-- verifie que le pokemon a ete apercu avant d'etre ajoutÃ©
  if p_apercu = 0 then
    RAISE pas_apercu;
  end if;
-- verifie si le numero du pokemon est bien mis en dernier
    if :NEW.numSpecimen <> (nbcap+1) THEN 
        :NEW.numSpecimen := nbcap+1;
  end if;
  
  EXCEPTION 
    WHEN pas_apercu Then
    RAISE_APPLICATION_ERROR(-20001, 'Le pokemon n"est pas apercu');
   
END Capture;
/



--Supprimez les rÃ´les existants qui sont en conflit avec ceux que vous essayez de crÃ©er :

DROP ROLE pokedex_manager;
-- CrÃ©er le rÃ´le POKEDEX_MANAGER pour l'utilisateur "L3_20"
CREATE ROLE pokedex_manager;

-- Attribuer des droits au rÃ´le POKEDEX_MANAGER
GRANT SELECT, INSERT, UPDATE, DELETE ON Pokedex TO pokedex_manager;
GRANT SELECT, INSERT, UPDATE, DELETE ON Specimen TO pokedex_manager;
GRANT SELECT, INSERT, UPDATE, DELETE ON Pokemon TO pokedex_manager;

-- Accorder le rÃ´le POKEDEX_MANAGER Ã  l'utilisateur L3_20 avec l'option ADMIN
GRANT pokedex_manager TO L3_20;

DROP ROLE dresseur_manager;

--Pour l'utilisateur "L3_32" :
-- CrÃ©er le rÃ´le dresseur_manager
CREATE ROLE dresseur_manager;

-- Attribuer des droits au rÃ´le dresseur_manager
GRANT SELECT, INSERT, UPDATE, DELETE ON Dresseur TO dresseur_manager;
GRANT SELECT, INSERT, UPDATE, DELETE ON Specimen TO dresseur_manager;
GRANT SELECT, INSERT, UPDATE, DELETE ON Pokedex TO dresseur_manager;

-- Accorder le rÃ´le dresseur_manager Ã  l'utilisateur L3_32
GRANT dresseur_manager TO L3_32;
