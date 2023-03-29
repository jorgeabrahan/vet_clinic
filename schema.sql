/* Database schema to keep the structure of entire database. */

/* Create a database named vet_clinic */
CREATE DATABASE vet_clinic;

/* Connect to database vet_clinic */
\c vet_clinic

/* Create table animals inside the vet_clinic database */
CREATE TABLE animals(
	id INT GENERATED ALWAYS AS IDENTITY,
	name VARCHAR(250),
	date_of_birth DATE,
	escape_attempts INT,
	neutered BOOLEAN,
	weight_kg DECIMAL,
	PRIMARY KEY(id)
);

/* Add a column species of type string to the animals table */
ALTER TABLE animals ADD species VARCHAR(250);

/* Create a table named owners */
CREATE TABLE owners(
	id INT GENERATED ALWAYS AS IDENTITY,
	full_name VARCHAR(250),
	age INT,
	PRIMARY KEY(id)
);

/* Create a table named species */
CREATE TABLE species(
	id INT GENERATED ALWAYS AS IDENTITY,
	name VARCHAR(250),
	PRIMARY KEY(id)
);