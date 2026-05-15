-- Auth Multi-Scheme POC — Deinstall Script
DROP PACKAGE xx_auth_pkg;
DROP TABLE xx_password_reset_tokens;
DROP TABLE xx_login_audit;
DROP TABLE xx_user_access_request;
DROP TABLE xx_user_passwords;
DROP TABLE xx_users;
DROP TABLE xx_app_parameters;
