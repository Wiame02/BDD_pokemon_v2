-- montre tous les specimens capturés d'un dresseur (ici 04)
SELECT numSpecimen,niveau,  vie, taille, poids, idpokemon
FROM Specimen
WHERE Specimen.idPokedex = 04;

--Montre le nombre de pokemon capturé par un dresseur
SELECT idPokedex, nbMemePoke
FROM Nbr_Pokemon_Capturer;

-- Ici exemple avec le dresseur dont l'idPokedex est 4
--Affichage de son pokedex
Select * 
FROM Pokedex
WHERE idPokedex = 04 ;

-- On essaie de capturer un pokemon non vu pour le trigger
-- !! ne marche pas -> malgré condition apercu = 0, le trigger ne se declanche pas
-- + met le numéro du specimen a 25 alors que la fonction permet de le mettre au nombre de pokemon dans specimen +1, et egalement un trigger pour s'en assurer

-- afin de verifier ces conditions, verifier avec les prochaines commandes les données (les memes que ce qui est données dans les fonctions)

--pour la mise a jour du numero du specimen
    SELECT nbPokemonCapture
    FROM Pokedex
    WHERE Pokedex.idPokemon = 01 AND Pokedex.idPokedex = 04 AND Pokedex.idDresseur = 108 ;   

-- pour la condition apercu = 0
    SELECT apercu
    FROM Pokedex
    WHERE Pokedex.idPokemon = 01 AND Pokedex.idPokedex = 04 AND Pokedex.idDresseur = 108 ;

-- l'insertion se fait quand meme ?? avec l'id 25 et sans que apercu soit a 1
call Capture(04,108 ,01);


-- !!!!!!!!! Dans le cas ou capture est fait, elle ne peut pas etre reappeler du a l'id 25 identique a l'insertion precedente. Il y a egalement le apercu a 0 et le capturer a 0 donc peut entrainer des erreurs non prevues. Si necessaire, refaire la suite creation/insertion/fct pour relancer le processus sans le capture




-- Decouverte du premier pokemon, et suite normal avec capture
call Decouverte(04,108,01); 

call Capture(04,108 ,01);


-- Pokemon a l'id 02 qui est apercu et capture dans le pokedex 04

SELECT apercu, capture
FROM Pokedex
WHERE  idPokedex = 04 AND idDresseur = 108 AND idPokemon = 02;

-- Il y a ici qu'un seul pokemon avec cet id
SELECT count(*)
FROM Specimen 
WHERE Specimen.idPokedex = 04 AND Specimen.idPokemon = 02;
	
-- le numSpecimen numero 01 correspond a celui du pokemon a l'id 02. On le relache donc
call Relacher(01,04); 

-- verification du fonctionnement, en un seul exemplaire donc egale a 0 si on regarde l'id du pokemon 02

SELECT count(*)
FROM Specimen 
WHERE Specimen.idPokedex = 04 AND Specimen.idPokemon = 02;

-- On reaffiche, pour voir la mise a jour des numeros de specimen dans le pokedex, et le fait que l'id 02 n'y est plus
SELECT numSpecimen,niveau,  vie, taille, poids, idpokemon
FROM Specimen
WHERE Specimen.idPokedex = 04;

-- On peut voir que son capture est bien noté a 0 vu qu'il ne l'est plus. 
Select * 
FROM Pokedex
WHERE idPokedex = 04 AND idPokemon = 02;

-- meme exemple avec le premier pokemon qui ici ne sera plus le seul avec cet id
call Relacher(01,04); 

SELECT count(*)
FROM Specimen 
WHERE Specimen.idPokedex = 04 AND Specimen.idPokemon = 30;

SELECT numSpecimen,niveau,  vie, taille, poids, idpokemon
FROM Specimen
WHERE Specimen.idPokedex = 04;

Select * 
FROM Pokedex
WHERE idPokedex = 04 AND idPokemon = 30;



	--pour utilisateur L3_32
-- InsÃ©rer des donnÃ©es dans la table Dresseur en utilisant les valeurs des sÃ©quences
INSERT INTO Dresseur (idDresseur, nom, prenom, adresse) VALUES (seq_dresseur_id.NEXTVAL, 'KETCHUM', 'Sacha', '5 rue du Bourg Palette, Kanto');
INSERT INTO Dresseur (idDresseur, nom, prenom, adresse) VALUES (seq_dresseur_id.NEXTVAL, 'MAY', 'Flora', '46 avenue d Oliville, Johto');
INSERT INTO Dresseur (idDresseur, nom, prenom, adresse) VALUES (seq_dresseur_id.NEXTVAL, 'CHEN', 'Regis', '11 rue d Argenta, Johto');
INSERT INTO Dresseur (idDresseur, nom, prenom, adresse) VALUES (seq_dresseur_id.NEXTVAL, 'MISTY', 'Ondine', '102 ArÃ¨ne Azuria, Kanto');

-- SÃ©lectionner des donnÃ©es depuis la table Dresseur pour vÃ©rifier l'insertion
SELECT * FROM Dresseur;

--pour utilisateur L3_20
-- Connexion Ã  la base de donnÃ©es en utilisant un compte utilisateur ayant le rÃ´le pokedex_manager

-- InsÃ©rer des donnÃ©es dans la table Pokedex
INSERT INTO Pokedex (idPokedex, idPokemon, idDresseur, apercu, capture, nbPokemonApercu, nbPokemonCapture) 
VALUES (seq_pokedex_id.nextval, seq_pokemon_id.nextval, 25, 1, 1, 27, 24);

INSERT INTO Pokedex (idPokedex, idPokemon, idDresseur, apercu, capture, nbPokemonApercu, nbPokemonCapture) 
VALUES (seq_pokedex_id.currval, seq_pokemon_id.nextval, 25, 1, 1, 27, 24);

INSERT INTO Pokedex (idPokedex, idPokemon, idDresseur, apercu, capture, nbPokemonApercu, nbPokemonCapture) 
VALUES (seq_pokedex_id.currval, seq_pokemon_id.nextval, 25, 1, 1, 27, 24);
-- SÃ©lectionner des donnÃ©es depuis la table Pokedex pour vÃ©rifier l'insertion
SELECT * FROM Pokedex;


