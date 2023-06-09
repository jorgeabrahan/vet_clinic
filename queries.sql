/*Queries that provide answers to the questions from all projects.*/

/* Find all animals whose name ends in "mon" */
SELECT * FROM animals WHERE name LIKE '%mon';

/* List the name of all animals born between 2016 and 2019 */
SELECT name FROM animals WHERE EXTRACT(YEAR FROM date_of_birth) BETWEEN 2016 AND 2019;

/* List the name of all animals that are neutered and have less than 3 escape attempts. */
SELECT name FROM animals WHERE neutered IS TRUE AND escape_attempts < 3;

/* List the date of birth of all animals named either "Agumon" or "Pikachu". */
SELECT date_of_birth FROM animals WHERE name IN ('Agumon', 'Pikachu');

/* List name and escape attempts of animals that weigh more than 10.5kg */
SELECT name, escape_attempts FROM animals WHERE weight_kg > 10.5;

/* Find all animals that are neutered. */
SELECT * FROM animals WHERE neutered IS TRUE;

/* Find all animals not named Gabumon. */
SELECT * FROM animals WHERE NOT name = 'Gabumon';

/* Find all animals with a weight between 10.4kg and 17.3kg (including the animals with the weights that equals precisely 10.4kg or 17.3kg) */
SELECT * FROM animals WHERE weight_kg >= 10.4 AND weight_kg <= 17.3;

/* it can also be done as shown: */
SELECT * FROM animals WHERE weight_kg BETWEEN 10.3 AND 17.4;



/*
1- Inside a transaction update the animals table by setting the species column to unspecified
*/
BEGIN;
UPDATE animals SET species = 'unspecified';
/* 
2- Verify that change was made
*/
SELECT * FROM animals;
/* 
3- Then roll back the change and verify that the species columns went back to the state before the transaction.
*/
ROLLBACK TRANSACTION;



/* 
Inside a transaction:
Update the animals table by setting the species column to digimon for all animals that have a name ending in mon.
*/
BEGIN;
UPDATE animals SET species = 'digimon' WHERE name LIKE '%mon';
/* 
Update the animals table by setting the species column to pokemon for all animals that don't have species already set.
*/
UPDATE animals SET species = 'pokemon' WHERE species IS NULL OR species = '';
/* 
Commit the transaction.
*/
COMMIT;
/*
Verify that change was made and persists after commit.
*/
SELECT * FROM animals;
ROLLBACK; /* This won't work */



/* Inside a transaction delete all records in the animals table */
BEGIN;
DELETE FROM animals;
/* verify all are deleted */
SELECT * FROM animals;
/* roll back the transaction */
ROLLBACK;



/* 
Inside a transaction:
Delete all animals born after Jan 1st, 2022
Check animals were deleted
*/
BEGIN; DELETE FROM animals WHERE EXTRACT(YEAR FROM date_of_birth) >= 2022 AND EXTRACT(MONTH FROM date_of_birth) >= 1 AND EXTRACT(DAY FROM date_of_birth) >= 1;
SELECT * FROM animals;
/* 
Create a savepoint for the transaction
Update all animals' weight to be their weight multiplied by -1
Check animals weight was updated
*/
SAVEPOINT BEFORE_WEIGHT_UPDATE; UPDATE animals SET weight_kg = weight_kg * -1;
SELECT * FROM animals;
/* 
Rollback to the savepoint
Check animals weight is back to the initial value
*/
ROLLBACK TO BEFORE_WEIGHT_UPDATE;
SELECT * FROM animals;
/* 
Update all animals' weights that are negative to be their weight multiplied by -1.
Commit transaction
*/
UPDATE animals SET weight_kg = weight_kg * -1 WHERE weight_kg < 0;
SELECT * FROM animals;
COMMIT;


/* 
Write queries to answer the following questions:
- How many animals are there?
*/
SELECT COUNT(*) FROM animals;

/* How many animals have never tried to escape? */
SELECT COUNT(*) FROM animals WHERE escape_attempts = 0;

/* What is the average weight of animals? */
SELECT AVG(weight_kg) FROM animals;

/* Who escapes the most, neutered or not neutered animals? */
SELECT neutered, SUM(escape_attempts) as total_attempts FROM animals GROUP BY neutered ORDER BY SUM(escape_attempts) DESC limit 1;

/* 
What is the minimum and maximum weight of each type of animal?
*/
SELECT species, MIN(weight_kg), MAX(weight_kg) FROM animals GROUP BY species; /* by species */
SELECT neutered, MIN(weight_kg), MAX(weight_kg) FROM animals GROUP BY neutered; /* by neutered */
SELECT MIN(weight_kg), MAX(weight_kg) FROM animals; /* min and max from all animals */

/* 
What is the average number of escape attempts per animal type of those born between 1990 and 2000?
*/
SELECT AVG(escape_attempts) FROM animals
WHERE EXTRACT(YEAR FROM date_of_birth) BETWEEN 1990 AND 2000 GROUP BY species;

/*
Write queries (using JOIN) to answer the following questions:
- What animals belong to Melody Pond?
*/
SELECT * FROM animals INNER JOIN owners ON animals.owner_id = owners.id
WHERE owners.full_name = 'Melody Pond';
/*
- List of all animals that are pokemon (their type is Pokemon).
*/
SELECT * FROM animals INNER JOIN species ON animals.species_id = species.id
WHERE species.name = 'Pokemon';
/*
- List all owners and their animals, remember to include those that don't own any animal.
*/
SELECT * FROM owners LEFT JOIN animals ON owners.id = animals.owner_id;
/*
- How many animals are there per species?
*/
SELECT species.name, COUNT(*) FROM species
INNER JOIN animals ON species.id = animals.species_id
GROUP BY species.name;
/*
- List all Digimon owned by Jennifer Orwell.
*/
SELECT * FROM animals
INNER JOIN species ON animals.species_id = species.id
INNER JOIN owners ON animals.owner_id = owners.id
WHERE species.name = 'Digimon' AND owners.full_name = 'Jennifer Orwell';
/*
- List all animals owned by Dean Winchester that haven't tried to escape.
*/
SELECT * FROM animals
INNER JOIN owners ON animals.owner_id = owners.id
WHERE owners.full_name = 'Dean Winchester' AND animals.escape_attempts = 0;
/*
- Who owns the most animals?
*/
SELECT owners_animals.full_name, count FROM
(
  SELECT owners.full_name, COUNT(*) FROM animals
  INNER JOIN owners ON animals.owner_id = owners.id
  GROUP BY owners.full_name
) as owners_animals
GROUP BY (full_name, count)
HAVING count = (
  SELECT MAX(count) FROM 
  (
    SELECT owners.full_name, COUNT(*) FROM animals
    INNER JOIN owners ON animals.owner_id = owners.id
    GROUP BY owners.full_name
  ) AS FOO
);


/*
Write queries to answer the following:
- Who was the last animal seen by William Tatcher?
*/
SELECT visits.id, vets.name, animals.name FROM visits
INNER JOIN animals ON animals.id = visits.animals_id
INNER JOIN vets ON vets.id = visits.vets_id
WHERE vets.name = 'William Tatcher'
ORDER BY visits.id DESC LIMIT 1;
/*
- How many different animals did Stephanie Mendez see?
*/
SELECT 'Stephanie Mendez' AS vet, COUNT(*) FROM
(
  SELECT vets.name, animals.name FROM visits
  INNER JOIN animals ON animals.id = visits.animals_id
  INNER JOIN vets ON vets.id = visits.vets_id
  WHERE vets.name = 'Stephanie Mendez'
) as FOO;
/*
- List all vets and their specialties, including vets with no specialties.
*/
SELECT * FROM specializations
RIGHT JOIN species ON species.id = specializations.species_id
RIGHT JOIN vets ON specializations.vets_id = vets.id;
/*
- List all animals that visited Stephanie Mendez between April 1st and August 30th, 2020.
*/
SELECT * FROM visits
INNER JOIN vets ON vets.id = visits.vets_id
INNER JOIN animals ON animals.id = visits.animals_id
WHERE vets.name = 'Stephanie Mendez'
AND EXTRACT(YEAR FROM visits.visit_date) = 2020
AND EXTRACT(MONTH FROM visits.visit_date) BETWEEN 4 AND 8;
/*
- What animal has the most visits to vets?
*/
SELECT animals_visits.name, count FROM
(
  SELECT animals.name, COUNT(*) FROM visits
  INNER JOIN animals ON visits.animals_id = animals.id
  GROUP BY animals.name
) as animals_visits
GROUP BY (animals_visits.name, count)
HAVING count = (
  SELECT MAX(count) FROM
  (
    SELECT animals.name, COUNT(*) FROM visits
    INNER JOIN animals ON visits.animals_id = animals.id
    GROUP BY animals.name
  ) as FOO
);
/* 
- Who was Maisy Smith's first visit?
*/
SELECT * FROM visits
INNER JOIN vets ON vets.id = visits.vets_id
INNER JOIN animals ON animals.id = visits.animals_id
WHERE vets.name = 'Maisy Smith' LIMIT 1;
/*
- Details for most recent visit: animal information, vet information, and date of visit.
*/
SELECT * FROM visits
INNER JOIN vets ON vets.id = visits.vets_id
INNER JOIN animals ON animals.id = visits.animals_id
WHERE visit_date = (SELECT MAX(visit_date) FROM visits);
/*
- How many visits were with a vet that did not specialize in that animal's species?
*/
SELECT COUNT(*) FROM 
(
  SELECT species_seen.vet_name, species_seen.specie_seen FROM 
  (
    SELECT vets.name as vet_name, species.name as specie_seen FROM visits 
    INNER JOIN vets ON vets.id = visits.vets_id 
    INNER JOIN animals ON animals.id = visits.animals_id 
    INNER JOIN species ON animals.species_id = species.id
  ) AS species_seen 
  WHERE specie_seen NOT IN ( 
    SELECT species.name as specialties FROM specializations
    INNER JOIN vets ON vets.id = specializations.vets_id 
    INNER JOIN species ON species.id = specializations.species_id 
    WHERE vets.name = species_seen.vet_name
  )
) AS FOO;
/*
- What specialty should Maisy Smith consider getting? Look for the species she gets the most.
*/
SELECT specie_seen as specie_seen_the_most, count FROM
(
  SELECT species.name as specie_seen, COUNT(species.name) FROM visits
  INNER JOIN vets ON vets.id = visits.vets_id
  INNER JOIN animals ON animals.id = visits.animals_id
  INNER JOIN species ON animals.species_id = species.id
  WHERE vets.name = 'Maisy Smith'
  GROUP BY species.name
) AS amount_species_seen
GROUP BY (specie_seen, count)
HAVING count = (
  SELECT MAX(count) FROM
  (
    SELECT species.name as specie_seen, COUNT(species.name) FROM visits
    INNER JOIN vets ON vets.id = visits.vets_id
    INNER JOIN animals ON animals.id = visits.animals_id
    INNER JOIN species ON animals.species_id = species.id
    WHERE vets.name = 'Maisy Smith'
    GROUP BY species.name
  ) AS FOO
);
