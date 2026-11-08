# KC Sactionlist API

# Sanctions Screening Service

An automated pipeline that collects public international sanctions lists, stores them in one normalised database, and exposes a secured REST API to check whether a person matches a sanctioned individual.

Built as part of a team project for a financial-services client (anti-money-laundering / KYC use case).

## What it does

1. **Collects** the sanctions lists from four public sources: UN Security Council, UK (OFSI), US (OFAC SDN) and EU (consolidated list).
2. **Normalises** the different formats (HTML, plain text, PDF) into a single schema: names, aliases, dates and places of birth, nationalities, ID numbers, addresses.
3. **Stores** the data in MySQL, refreshing each source's records on every run.
4. **Serves** a REST API: a client sends a person's details and receives a match result.

## Architecture

```
 UN / UK / US / EU sources (HTML, TXT, PDF)
              |
     scraper/  (Python, Selenium, BeautifulSoup, PyPDF2)
              |
        MySQL: sanctions_list
              |
     api/  (Node.js, TypeScript, Express, JWT)
              |
     gateway/  (Kong)  ->  client applications
```

## Tech stack

| Layer | Technologies |
|---|---|
| Scraper | Python 3, Selenium (headless Firefox), BeautifulSoup, html5lib, PyPDF2, PyYAML |
| Database | MySQL (JSON columns for multi-value fields, stored procedure and functions for matching) |
| API | Node.js, TypeScript, Express, JSON Web Tokens, express-validator, Swagger UI |
| Quality | Jest + Supertest, ESLint, Prettier |
| Deployment | Docker, Kong API gateway |

## Project structure

```
sanctions-screening/
├── scraper/
│   ├── main.py                  # runs all parsers and loads the database
│   ├── data_parser.py           # coordinates parsers and DB insertion
│   ├── db_manager.py            # table creation, inserts, deletes
│   ├── configuration/           # source URLs (YAML) + env-based DB settings
│   ├── rbi_parser/              # UN lists
│   ├── uk_parser/
│   ├── us_parser/
│   └── eu_parser/               # downloads and parses the PDF list
├── api/
│   ├── src/
│   │   ├── router/              # HTTP routes and input validation
│   │   ├── service/             # business logic
│   │   ├── middleware/          # JWT check, error handling
│   │   ├── database/            # connection
│   │   └── swagger.json         # API documentation
│   ├── test/
│   ├── dbScript.sql             # tables, validate_user procedure, matching functions
│   └── Dockerfile
└── gateway/kong.yml
```

## API

| Method | Endpoint | Description |
|---|---|---|
| POST | `/api/auth/login` | Log in with username and password, returns a JWT |
| GET | `/api/user/validate` | Check a person against the sanctions data (JWT required) |
| GET | `/api-docs` | Interactive Swagger documentation |

`/api/user/validate` accepts any combination of: `name`, `dob`, `pob`, `gender`, `nationality`, `address`, `email`, `passport_no`, `national_identification_no`, `drivers_license_no`, `aadhar_no`, `pan_no`.

Matching is done in the database: first a direct check on identifiers and name, then a partial-match pass over name and aliases, date and place of birth, address, gender, nationality and ID numbers.

Example:

```bash
TOKEN=$(curl -s -X POST localhost:5000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"user@example.com","password":"..."}' | jq -r .accessToken)

curl -H "Authorization: $TOKEN" \
  "localhost:5000/api/user/validate?name=John%20Doe&dob=1980-01-01"
```

## Setup

Requirements: Python 3.9+, Node.js 16+, MySQL 8, Firefox (for Selenium).

**1. Configure environment** (copy `.env.example` to `.env`)

```
DB_NAME, DB_USER, DB_PWD, DB_HOST, DB_PORT     # scraper
DB_USERNAME, DB_PASSWORD                       # API
SECRET_KEY, TOKEN_EXPIRY, DB_TIMEOUT, PORT     # API
API_DOC_HOST, API_DOC_PORT                     # Swagger
```

**2. Create the database objects**

```bash
mysql -u <user> -p <db_name> < api/dbScript.sql
```

**3. Load the sanctions data**

```bash
cd scraper
pip install -r requirements.txt
python main.py
```

**4. Start the API**

```bash
cd api
npm install
npm run dev          # development
npm test             # tests
```

## Design decisions

- **One parser per source.** Each list has its own format and quirks, so every source is an independent module that returns the same record structure. Adding a source means adding one module.
- **Refresh by source.** Before inserting, the pipeline deletes only that source's previous records, so a failed download never wipes the other sources.
- **JSON columns** keep multi-value fields (aliases, passports, addresses) in one row per listed person.
- **Configuration outside the code.** Source URLs are in YAML; credentials come from environment variables.

## My contribution

- Wrote and tested web scrapers for the sanctions sources using Selenium and BeautifulSoup
- Filtered and cleaned the scraped data into a common schema
- Added new features as per client requirements
- Made the database connection configurable and loaded the data into MySQL

The REST API layer was developed with the help of a teammate.

## Planned improvements

- Parameterised SQL queries throughout the API
- Hash passwords (bcrypt) instead of reversible encryption
- Scheduled runs (cron/Airflow) and parser unit tests with saved sample files
- Multi-stage Docker build and `docker-compose` for the full stack
