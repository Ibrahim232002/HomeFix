# Database seed-data policy

Production deployments must not use development/demo accounts or sample data.

The former `SeedData.sql` development account script has been removed from the production-hardening branch. Populate development/test data through an explicitly isolated local fixture or test database instead.

Do not commit real passwords, password hashes, API keys, OTPs, access tokens, refresh tokens, SMTP credentials, or other production secrets to this repository.
