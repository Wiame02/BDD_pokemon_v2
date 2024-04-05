
DROP TABLE Pokemon CASCADE CONSTRAINTS;
DROP TABLE Pokedex CASCADE CONSTRAINTS;
DROP TABLE Specimen CASCADE CONSTRAINTS;
DROP TABLE Dresseur CASCADE CONSTRAINTS;
DROP TABLE FacteursEspece CASCADE CONSTRAINTS;

CREATE TABLE Pokemon(
  idPokemon 	NUMBER NOT NULL, 
  Type1 		VARCHAR2(20),
  Type2		VARCHAR2(20),
  nomEspece	VARCHAR2(20),
  CONSTRAINT pk_Pokemon PRIMARY KEY (idPokemon)
);

CREATE TABLE Dresseur(
  idDresseur 	NUMBER,
  nom			VARCHAR2(50),
  prenom		VARCHAR2(50),
  adresse		VARCHAR2(50),
  idPokedex 	NUMBER,
  CONSTRAINT pk_dresseur PRIMARY KEY (idDresseur)
);

CREATE TABLE Pokedex(
  idPokedex 	NUMBER,
  idPokemon 	NUMBER,
  idDresseur	NUMBER,
  apercu		NUMBER(1),
  capture		NUMBER(1),
  nbPokemonApercu 	NUMBER,
  nbPokemonCapture 	NUMBER,
  CONSTRAINT ck_bool_apercu CHECK (apercu IN (1,0)),
  CONSTRAINT ck_bool_capture CHECK (capture IN (1,0)),
  CONSTRAINT pasApercuNega CHECK (nbPokemonApercu >= 0),
  CONSTRAINT pasCaptureNega CHECK (nbPokemonCapture >= 0),
    CONSTRAINT pk_Pokedex PRIMARY KEY (idPokedex, idPokemon, idDresseur),
    CONSTRAINT fk_Pokemon_Pokedex FOREIGN KEY (idPokemon) REFERENCES Pokemon(idPokemon),
    CONSTRAINT fk_Dresseur_Pokedew FOREIGN KEY (idDresseur) REFERENCES Dresseur(idDresseur)
);

CREATE TABLE FacteursEspece (
  espece VARCHAR2(20),
  facteurVie FLOAT,
  facteurTaille FLOAT, 
  facteurPoids FLOAT,
  CONSTRAINT pk_facteursEspece PRIMARY KEY (espece)
);


CREATE TABLE Specimen(
  numSpecimen	NUMBER,
  niveau		NUMBER,
  vie           NUMBER,
  taille    NUMBER,
  poids     NUMBER,
  idPokedex 	NUMBER,
  idPokemon	NUMBER,
  CONSTRAINT pasNiveauNega CHECK (niveau > 0),
  CONSTRAINT pasVieNega CHECK (vie > 0),
  CONSTRAINT pasTailleNega CHECK (taille > 0),
  CONSTRAINT pasPoidsNega CHECK (poids > 0),
  CONSTRAINT pk_specimen PRIMARY KEY (numSpecimen, idPokedex, idPokemon),
  CONSTRAINT fk_Pokemon_Specimen FOREIGN KEY (idPokemon) REFERENCES Pokemon(idPokemon)
);

