#  Country Capitals Finder (Bash Script)

##  Problem Statement

1. Create an associative array of country-capital pairs
2. Write a function that asks the user for a country and returns its capital
3. Implement error handling for countries not in the array

---

##  Solution

This Bash script uses:

* An **associative array** (`declare -A`) to store **Country → Capital** pairs
* A **function `get_capital`** that:

  1. Prompts the user to enter a country name
  2. Looks up the capital in the associative array
  3. Prints the result if found, otherwise shows a "not found" message

---


### Result

```bash
javeria_1207@Javeria:/mnt/d/training_session/training_session/Week_01/lab_03/capital_country$ ./country_capital.sh
enter a country name
Pakistan
The capital of Pakistan is: Islamabad
javeria_1207@Javeria:/mnt/d/training_session/training_session/Week_01/lab_03/capital_country$ ./country_capital.sh
enter a country name
Turkey
The capital of Turkey is: Ankara
javeria_1207@Javeria:/mnt/d/training_session/training_session/Week_01/lab_03/capital_country$ ./country_capital.sh
enter a country name
Portugal
The capital of Portugal is: Lisbon
javeria_1207@Javeria:/mnt/d/training_session/training_session/Week_01/lab_03/capital_country$ ./country_capital.sh
enter a country name
France
The capital of France is: Paris
javeria_1207@Javeria:/mnt/d/training_session/training_session/Week_01/lab_03/capital_country$ ./country_capital.sh
enter a country name
Syria
The capital of Syria is: Damascus
javeria_1207@Javeria:/mnt/d/training_session/training_session/Week_01/lab_03/capital_country$ ./country_capital.sh
enter a country name
Egypt
The capital of Egypt is: Cairo
javeria_1207@Javeria:/mnt/d/training_session/training_session/Week_01/lab_03/capital_country$ ./country_capital.sh
enter a country name
Qatar
The capital of Qatar is: Doha
javeria_1207@Javeria:/mnt/d/training_session/training_session/Week_01/lab_03/capital_country$ ./country_capital.sh
enter a country name
Kawait
The capital of Kawait is: Kuwait City
javeria_1207@Javeria:/mnt/d/training_session/training_session/Week_01/lab_03/capital_country$ ./country_capital.sh
enter a country name
Spain
The capital of Spain is: Madrid
javeria_1207@Javeria:/mnt/d/training_session/training_session/Week_01/lab_03/capital_country$ ./country_capital.sh
enter a country name
iceland
Capital for 'iceland' was not found in the list.
```

###  How to run

1. Save the script as `capitals.sh`
2. Make it executable:

   ```bash
   chmod +x capitals.sh
   ```
3. Run the script:

   ```bash
   ./capitals.sh
   ```
---

### Sources
* https://unix.stackexchange.com/questions/564927/dictionary-in-shell-script-only-showing-last-associated-item
* Chatgpt