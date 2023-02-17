-- 1. 
--     a. Which prescriber had the highest total number of claims (totaled over all drugs)? Report the npi and the total number of claims.
    
	SELECT md.npi, md.nppes_provider_last_org_name, sc.drug_name, sc.total_claim_count
	FROM prescriber AS md
		INNER join prescription AS sc USING (npi)
	ORDER BY sc.total_claim_count DESC;
	
-- 	ANSWER: 1912011792	"COFFEY"	"OXYCODONE HCL"	4538
	
--     b. Repeat the above, but this time report the nppes_provider_first_name, nppes_provider_last_org_name,  specialty_description, and the total number of claims.

	SELECT md.npi, md.nppes_provider_last_org_name, md.nppes_provider_first_name, md.specialty_description, sc.total_claim_count
	FROM prescriber AS md
		INNER join prescription AS sc USING (npi)
	ORDER BY sc.total_claim_count DESC;
	
-- 	ANSWER: 1912011792	"COFFEY"	"DAVID"	"Family Practice"	4538	

-- 2. 
--     a. Which specialty had the most total number of claims (totaled over all drugs)?

	SELECT DISTINCT md.specialty_description, SUM(sc.total_claim_count) AS number_of_claims
	FROM prescriber AS md
		INNER JOIN prescription AS sc USING (npi)
	GROUP BY md.specialty_description
	ORDER BY number_of_claims DESC;
	
-- 	ANSWER: "Family Practice"	9752347

--     b. Which specialty had the most total number of claims for opioids?

	SELECT md.specialty_description, COUNT(d.opioid_drug_flag) AS drug_count
	FROM prescriber AS md
		INNER JOIN prescription AS sc USING (npi)
		INNER JOIN drug AS d USING (drug_name)
	WHERE d.opioid_drug_flag = 'Y'
	GROUP BY md.specialty_description
	ORDER BY drug_count DESC;

-- 	ANSWER: "Nurse Practitioner"	9551

--     c. **Challenge Question:** Are there any specialties that appear in the prescriber table that have no associated prescriptions in the prescription table?

	SELECT md.specialty_description, COUNT(sc.drug_name) AS drug_number
	FROM prescriber AS md 
		LEFT JOIN prescription AS sc USING (npi)
	GROUP BY md.specialty_description
	ORDER BY drug_number ASC;
	
--     d. **Difficult Bonus:** *Do not attempt until you have solved all other problems!* For each specialty, report the percentage of total claims by that specialty which are for opioids. Which specialties have a high percentage of opioids?

-- 3. 
--     a. Which drug (generic_name) had the highest total drug cost?

	SELECT sc.drug_name, d.generic_name, sc.total_drug_cost
	FROM prescription AS sc
		INNER JOIN drug AS d USING (drug_name)
	WHERE sc.total_drug_cost IS NOT NULL
	ORDER BY sc.total_drug_cost DESC
	
-- 	ANSWER: "ESBRIET"	"PIRFENIDONE"	2829174.3

--     b. Which drug (generic_name) has the hightest total cost per day? **Bonus: Round your cost per day column to 2 decimal places. Google ROUND to see how this works.**

	SELECT sc.drug_name, d.generic_name, ROUND(sc.total_drug_cost/sc.total_day_supply,2) AS cost_per_day
	FROM prescription AS sc
		INNER JOIN drug AS d USING (drug_name)
	ORDER BY cost_per_day DESC

-- 	ANSWER: "GAMMAGARD LIQUID"	"IMMUN GLOB G(IGG)/GLY/IGA OV50"	7141.11

-- 4. 
--     a. For each drug in the drug table, return the drug name and then a column named 'drug_type' which says 'opioid' for drugs which have opioid_drug_flag = 'Y', says 'antibiotic' for those drugs which have antibiotic_drug_flag = 'Y', and says 'neither' for all other drugs.

	SELECT drug_name,
		(CASE WHEN opioid_drug_flag = 'Y' THEN 'opioid'
			 WHEN antibiotic_drug_flag = 'Y' THEN 'antibiotic'
			ELSE 'neither' END) AS drug_type
	FROM drug

--     b. Building off of the query you wrote for part a, determine whether more was spent (total_drug_cost) on opioids or on antibiotics. Hint: Format the total costs as MONEY for easier comparision.

	SELECT 
		(CASE WHEN d.opioid_drug_flag = 'Y' THEN 'opioid'
			 WHEN d.antibiotic_drug_flag = 'Y' THEN 'antibiotic'
			ELSE 'neither' END) AS drug_type,
		MONEY(SUM(sc.total_drug_cost)) AS cost
	FROM drug AS d
		INNER JOIN prescription AS sc USING (drug_name)
	WHERE d.opioid_drug_flag = 'Y' 
		OR d.antibiotic_drug_flag = 'Y'
	GROUP BY drug_type
	ORDER BY cost DESC

-- 	ANSWER: "opioid"	"$105,080,626.37"
	
-- 5. 
--     a. How many CBSAs are in Tennessee? **Warning:** The cbsa table contains information for all states, not just Tennessee.

	SELECT DISTINCT cbsaname
	FROM cbsa
	WHERE cbsaname LIKE '%TN%'

-- 	ANSWER: 10

--     b. Which cbsa has the largest combined population? Which has the smallest? Report the CBSA name and total population.

	SELECT cb.cbsaname, SUM(pop.population) AS popula
	FROM cbsa AS cb
		INNER JOIN population AS pop USING (fipscounty)
	WHERE cb.cbsaname LIKE '%TN%'
	GROUP BY cb.cbsaname
	ORDER BY popula DESC

-- 	ANSWER: Largest - "Nashville-Davidson--Murfreesboro--Franklin, TN", Smallest - "Morristown, TN"

--     c. What is the largest (in terms of population) county which is not included in a CBSA? Report the county name and population.

	SELECT pop.fipscounty, pop.population, fip.county, cb.cbsaname
	FROM population AS pop
		LEFT JOIN cbsa AS cb USING (fipscounty)
		INNER JOIN fips_county AS fip USING (fipscounty)
	WHERE cb.cbsaname IS NULL
	ORDER BY population DESC

-- 	ANSWER: 95523	"SEVIER"

-- 6. 
--     a. Find all rows in the prescription table where total_claims is at least 3000. Report the drug_name and the total_claim_count.

	SELECT drug_name, total_claim_count
	FROM prescription
	WHERE total_claim_count >= 3000

--     b. For each instance that you found in part a, add a column that indicates whether the drug is an opioid.

	SELECT d.drug_name, sc.total_claim_count, d.opioid_drug_flag
	FROM prescription AS sc
		INNER JOIN drug AS d USING (drug_name)
	WHERE total_claim_count >= 3000

--     c. Add another column to you answer from the previous part which gives the prescriber first and last name associated with each row.

	SELECT d.drug_name, sc.total_claim_count, d.opioid_drug_flag, md.nppes_provider_first_name, md.nppes_provider_last_org_name
		FROM prescription AS sc
			INNER JOIN drug AS d USING (drug_name)
			INNER JOIN prescriber AS md USING (npi)
		WHERE total_claim_count >= 3000

-- 7. The goal of this exercise is to generate a full list of all pain management specialists in Nashville and the number of claims they had for each opioid. **Hint:** The results from all 3 parts will have 637 rows.

--     a. First, create a list of all npi/drug_name combinations for pain management specialists (specialty_description = 'Pain Managment') in the city of Nashville (nppes_provider_city = 'NASHVILLE'), where the drug is an opioid (opiod_drug_flag = 'Y'). **Warning:** Double-check your query before running it. You will only need to use the prescriber and drug tables since you don't need the claims numbers yet.

	SELECT md.npi, d.drug_name
	FROM prescriber AS md
		cross JOIN prescription AS sc
		cross JOIN drug AS d
	WHERE md.specialty_description LIKE 'Pain Management'
		AND md.nppes_provider_city LIKE 'NASHVILLE'
		AND d.opioid_drug_flag LIKE 'Y'

--     b. Next, report the number of claims per drug per prescriber. Be sure to include all combinations, whether or not the prescriber had any claims. You should report the npi, the drug name, and the number of claims (total_claim_count).
    
	SELECT md.npi, md.nppes_provider_last_org_name, sc.drug_name, d.opioid_drug_flag, sc.total_claim_count
	FROM prescriber AS md
		LEFT JOIN prescription AS sc USING (npi)
		LEFT JOIN drug AS d USING (drug_name)
	WHERE md.specialty_description LIKE 'Pain Management'
		AND md.nppes_provider_city LIKE 'NASHVILLE'
		AND d.opioid_drug_flag LIKE 'Y'
	ORDER BY sc.total_claim_count DESC
	
--     c. Finally, if you have not done so already, fill in any missing values for total_claim_count with 0. Hint - Google the COALESCE function.
