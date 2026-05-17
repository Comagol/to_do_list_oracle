-- Package + parameter seeds only — use when tables/indexes already exist.
-- Avoids ORA-00955 from re-running full install-script.sql DDL.
-- Keep install-script.sql for brand-new schemas; use this file for upgrades / package fixes.

-- ── XX_AUTH_PKG ──
CREATE OR REPLACE PACKAGE xx_auth_pkg AS
    FUNCTION hash_password (p_password IN VARCHAR2, p_salt IN VARCHAR2) RETURN VARCHAR2;
    FUNCTION generate_salt RETURN VARCHAR2;
    FUNCTION authenticate  (p_username IN VARCHAR2, p_password IN VARCHAR2) RETURN BOOLEAN;
    PROCEDURE change_password (p_user_id IN NUMBER, p_new_password IN VARCHAR2, p_changed_by IN VARCHAR2 DEFAULT NULL);
    FUNCTION check_password_history (p_user_id IN NUMBER, p_new_password IN VARCHAR2, p_history_count IN NUMBER DEFAULT 5) RETURN BOOLEAN;
    FUNCTION generate_reset_token  (p_user_id IN NUMBER) RETURN VARCHAR2;
    FUNCTION validate_reset_token  (p_token IN VARCHAR2) RETURN NUMBER;
    PROCEDURE lock_account   (p_user_id IN NUMBER, p_reason IN VARCHAR2);
    PROCEDURE unlock_account (p_user_id IN NUMBER);
    PROCEDURE record_login_attempt (p_user_id IN NUMBER DEFAULT NULL, p_username IN VARCHAR2, p_login_type IN VARCHAR2, p_success IN VARCHAR2, p_failure_reason IN VARCHAR2 DEFAULT NULL, p_ip_address IN VARCHAR2 DEFAULT NULL, p_user_agent IN VARCHAR2 DEFAULT NULL);
    FUNCTION get_parameter (p_name IN VARCHAR2) RETURN VARCHAR2;
    FUNCTION apex_authenticate (p_username IN VARCHAR2, p_password IN VARCHAR2) RETURN BOOLEAN;
END xx_auth_pkg;
/

CREATE OR REPLACE PACKAGE BODY xx_auth_pkg AS

    FUNCTION hash_password (p_password IN VARCHAR2, p_salt IN VARCHAR2) RETURN VARCHAR2 IS
        v_hex VARCHAR2(512);
    BEGIN
        SELECT RAWTOHEX(STANDARD_HASH(NVL(p_salt, '') || NVL(p_password, ''), 'SHA512'))
        INTO v_hex FROM dual;
        RETURN v_hex;
    END hash_password;

    FUNCTION generate_salt RETURN VARCHAR2 IS
    BEGIN
        RETURN LOWER(
            RAWTOHEX(SYS_GUID()) || RAWTOHEX(SYS_GUID())
        );
    END generate_salt;

    FUNCTION get_parameter (p_name IN VARCHAR2) RETURN VARCHAR2 IS
        v_val VARCHAR2(4000);
    BEGIN
        SELECT parameter_value INTO v_val FROM xx_app_parameters WHERE UPPER(parameter_name) = UPPER(p_name);
        RETURN v_val;
    EXCEPTION WHEN NO_DATA_FOUND THEN RETURN NULL;
    END get_parameter;

    PROCEDURE record_login_attempt (p_user_id IN NUMBER DEFAULT NULL, p_username IN VARCHAR2, p_login_type IN VARCHAR2, p_success IN VARCHAR2, p_failure_reason IN VARCHAR2 DEFAULT NULL, p_ip_address IN VARCHAR2 DEFAULT NULL, p_user_agent IN VARCHAR2 DEFAULT NULL) IS
        PRAGMA AUTONOMOUS_TRANSACTION;
    BEGIN
        INSERT INTO xx_login_audit (user_id, username_attempted, login_type, success, failure_reason, ip_address, user_agent)
        VALUES (p_user_id, p_username, p_login_type, p_success, p_failure_reason, p_ip_address, p_user_agent);
        COMMIT;
    END record_login_attempt;

    PROCEDURE lock_account (p_user_id IN NUMBER, p_reason IN VARCHAR2) IS
    BEGIN
        UPDATE xx_users SET is_locked = 'Y', lock_reason = p_reason, locked_at = SYSTIMESTAMP, updated_at = SYSTIMESTAMP WHERE id = p_user_id;
        COMMIT;
    END lock_account;

    PROCEDURE unlock_account (p_user_id IN NUMBER) IS
    BEGIN
        UPDATE xx_users SET is_locked = 'N', lock_reason = NULL, locked_at = NULL, failed_login_attempts = 0, force_password_change = 'Y', updated_at = SYSTIMESTAMP WHERE id = p_user_id;
        COMMIT;
    END unlock_account;

    FUNCTION authenticate (p_username IN VARCHAR2, p_password IN VARCHAR2) RETURN BOOLEAN IS
        v_user_id NUMBER; v_is_active VARCHAR2(1); v_is_locked VARCHAR2(1); v_failed_count NUMBER;
        v_pwd_hash VARCHAR2(512); v_pwd_salt VARCHAR2(256); v_computed VARCHAR2(512); v_max NUMBER;
    BEGIN
        BEGIN
            SELECT id, is_active, is_locked, failed_login_attempts INTO v_user_id, v_is_active, v_is_locked, v_failed_count
            FROM xx_users WHERE UPPER(username) = UPPER(p_username);
        EXCEPTION WHEN NO_DATA_FOUND THEN
            record_login_attempt(p_username => p_username, p_login_type => 'PASSWORD', p_success => 'N', p_failure_reason => 'USER_NOT_FOUND');
            RETURN FALSE;
        END;
        IF v_is_active = 'N' THEN
            record_login_attempt(p_user_id => v_user_id, p_username => p_username, p_login_type => 'PASSWORD', p_success => 'N', p_failure_reason => 'ACCOUNT_INACTIVE');
            RETURN FALSE;
        END IF;
        IF v_is_locked = 'Y' THEN
            record_login_attempt(p_user_id => v_user_id, p_username => p_username, p_login_type => 'PASSWORD', p_success => 'N', p_failure_reason => 'ACCOUNT_LOCKED');
            RETURN FALSE;
        END IF;
        BEGIN
            SELECT password_hash, password_salt INTO v_pwd_hash, v_pwd_salt FROM xx_user_passwords WHERE user_id = v_user_id AND is_active = 'Y';
        EXCEPTION WHEN NO_DATA_FOUND THEN
            record_login_attempt(p_user_id => v_user_id, p_username => p_username, p_login_type => 'PASSWORD', p_success => 'N', p_failure_reason => 'NO_ACTIVE_PASSWORD');
            RETURN FALSE;
        END;
        v_computed := hash_password(p_password, v_pwd_salt);
        IF v_computed = v_pwd_hash THEN
            UPDATE xx_users SET failed_login_attempts = 0, last_login_at = SYSTIMESTAMP, updated_at = SYSTIMESTAMP WHERE id = v_user_id;
            record_login_attempt(p_user_id => v_user_id, p_username => p_username, p_login_type => 'PASSWORD', p_success => 'Y');
            RETURN TRUE;
        ELSE
            v_failed_count := v_failed_count + 1;
            v_max := NVL(TO_NUMBER(get_parameter('MAX_FAILED_LOGIN_ATTEMPTS')), 5);
            UPDATE xx_users SET failed_login_attempts = v_failed_count, updated_at = SYSTIMESTAMP WHERE id = v_user_id;
            IF v_failed_count >= v_max THEN lock_account(v_user_id, 'MAX_FAILED_ATTEMPTS_EXCEEDED'); END IF;
            record_login_attempt(p_user_id => v_user_id, p_username => p_username, p_login_type => 'PASSWORD', p_success => 'N', p_failure_reason => 'INVALID_PASSWORD');
            RETURN FALSE;
        END IF;
    END authenticate;

    FUNCTION check_password_history (p_user_id IN NUMBER, p_new_password IN VARCHAR2, p_history_count IN NUMBER DEFAULT 5) RETURN BOOLEAN IS
    BEGIN
        FOR rec IN (SELECT password_hash, password_salt FROM xx_user_passwords WHERE user_id = p_user_id ORDER BY created_at DESC FETCH FIRST p_history_count ROWS ONLY) LOOP
            IF hash_password(p_new_password, rec.password_salt) = rec.password_hash THEN RETURN FALSE; END IF;
        END LOOP;
        RETURN TRUE;
    END check_password_history;

    PROCEDURE change_password (p_user_id IN NUMBER, p_new_password IN VARCHAR2, p_changed_by IN VARCHAR2 DEFAULT NULL) IS
        v_salt VARCHAR2(256); v_hash VARCHAR2(512); v_hist NUMBER;
    BEGIN
        v_hist := NVL(TO_NUMBER(get_parameter('PASSWORD_HISTORY_COUNT')), 5);
        IF NOT check_password_history(p_user_id, p_new_password, v_hist) THEN
            raise_application_error(-20001, 'Password was recently used. Choose a different password.');
        END IF;
        UPDATE xx_user_passwords SET is_active = 'N' WHERE user_id = p_user_id AND is_active = 'Y';
        v_salt := generate_salt; v_hash := hash_password(p_new_password, v_salt);
        INSERT INTO xx_user_passwords (user_id, password_hash, password_salt, is_active, created_by) VALUES (p_user_id, v_hash, v_salt, 'Y', NVL(p_changed_by, 'SYSTEM'));
        UPDATE xx_users SET password_changed_at = SYSTIMESTAMP, password_expires_at = SYSTIMESTAMP + NUMTODSINTERVAL(NVL(TO_NUMBER(get_parameter('PASSWORD_EXPIRATION_DAYS')), 90), 'DAY'), force_password_change = 'N', updated_at = SYSTIMESTAMP, updated_by = NVL(p_changed_by, 'SYSTEM') WHERE id = p_user_id;
        COMMIT;
    END change_password;

    FUNCTION generate_reset_token (p_user_id IN NUMBER) RETURN VARCHAR2 IS
        v_token VARCHAR2(512); v_hash VARCHAR2(512); v_min NUMBER;
    BEGIN
        v_token := LOWER(
            RAWTOHEX(SYS_GUID()) || RAWTOHEX(SYS_GUID()) ||
            RAWTOHEX(SYS_GUID()) || RAWTOHEX(SYS_GUID())
        );
        SELECT RAWTOHEX(STANDARD_HASH(v_token, 'SHA512')) INTO v_hash FROM dual;
        v_min   := NVL(TO_NUMBER(get_parameter('FORGET_PASSWORD_TOKEN_EXPIRATION')), 60);
        UPDATE xx_password_reset_tokens SET is_used = 'Y', used_at = SYSTIMESTAMP WHERE user_id = p_user_id AND is_used = 'N';
        INSERT INTO xx_password_reset_tokens (user_id, token_hash, expires_at) VALUES (p_user_id, v_hash, SYSTIMESTAMP + NUMTODSINTERVAL(v_min, 'MINUTE'));
        COMMIT;
        RETURN v_token;
    END generate_reset_token;

    FUNCTION validate_reset_token (p_token IN VARCHAR2) RETURN NUMBER IS
        v_hash VARCHAR2(512); v_uid NUMBER;
    BEGIN
        IF p_token IS NULL THEN RETURN NULL; END IF;
        SELECT RAWTOHEX(STANDARD_HASH(TRIM(p_token), 'SHA512')) INTO v_hash FROM dual;
        SELECT user_id INTO v_uid FROM xx_password_reset_tokens WHERE token_hash = v_hash AND is_used = 'N' AND expires_at > SYSTIMESTAMP;
        UPDATE xx_password_reset_tokens SET is_used = 'Y', used_at = SYSTIMESTAMP WHERE token_hash = v_hash;
        COMMIT;
        RETURN v_uid;
    EXCEPTION WHEN NO_DATA_FOUND THEN RETURN NULL;
    END validate_reset_token;

    FUNCTION apex_authenticate (p_username IN VARCHAR2, p_password IN VARCHAR2) RETURN BOOLEAN IS
    BEGIN
        RETURN authenticate(p_username, p_password);
    END apex_authenticate;

END xx_auth_pkg;
/

-- Standalone auth function for APEX Custom Authentication (Authentication Function Name field).
-- Do not put "return xx_auth_pkg..." in PL/SQL Source — APEX validation raises PLS-00488.
CREATE OR REPLACE FUNCTION apex_app_authenticate (
    p_username IN VARCHAR2,
    p_password IN VARCHAR2
) RETURN BOOLEAN
IS
BEGIN
    RETURN xx_auth_pkg.authenticate(p_username, p_password);
END apex_app_authenticate;
/

INSERT INTO xx_app_parameters (parameter_name, parameter_value, description, created_by, updated_by)
SELECT 'FORGET_PASSWORD_TOKEN_EXPIRATION', '60', 'Token expiration in minutes for the forgot-password flow', 'SYSTEM', 'SYSTEM' FROM dual
WHERE NOT EXISTS (SELECT 1 FROM xx_app_parameters WHERE UPPER(parameter_name) = 'FORGET_PASSWORD_TOKEN_EXPIRATION');
INSERT INTO xx_app_parameters (parameter_name, parameter_value, description, created_by, updated_by)
SELECT 'MAX_FAILED_LOGIN_ATTEMPTS', '5', 'Maximum consecutive failed logins before account lockout', 'SYSTEM', 'SYSTEM' FROM dual
WHERE NOT EXISTS (SELECT 1 FROM xx_app_parameters WHERE UPPER(parameter_name) = 'MAX_FAILED_LOGIN_ATTEMPTS');
INSERT INTO xx_app_parameters (parameter_name, parameter_value, description, created_by, updated_by)
SELECT 'LOCKOUT_DURATION_MINUTES', '30', 'Duration in minutes an account stays locked after max failures', 'SYSTEM', 'SYSTEM' FROM dual
WHERE NOT EXISTS (SELECT 1 FROM xx_app_parameters WHERE UPPER(parameter_name) = 'LOCKOUT_DURATION_MINUTES');
INSERT INTO xx_app_parameters (parameter_name, parameter_value, description, created_by, updated_by)
SELECT 'PASSWORD_EXPIRATION_DAYS', '90', 'Days until a password expires and must be changed', 'SYSTEM', 'SYSTEM' FROM dual
WHERE NOT EXISTS (SELECT 1 FROM xx_app_parameters WHERE UPPER(parameter_name) = 'PASSWORD_EXPIRATION_DAYS');
INSERT INTO xx_app_parameters (parameter_name, parameter_value, description, created_by, updated_by)
SELECT 'PASSWORD_HISTORY_COUNT', '5', 'Number of previous passwords checked to prevent reuse', 'SYSTEM', 'SYSTEM' FROM dual
WHERE NOT EXISTS (SELECT 1 FROM xx_app_parameters WHERE UPPER(parameter_name) = 'PASSWORD_HISTORY_COUNT');
INSERT INTO xx_app_parameters (parameter_name, parameter_value, description, created_by, updated_by)
SELECT 'RESET_TOKEN_LENGTH', '128', 'Generated reset-token length (hex characters; ~entropy from GUIDs)', 'SYSTEM', 'SYSTEM' FROM dual
WHERE NOT EXISTS (SELECT 1 FROM xx_app_parameters WHERE UPPER(parameter_name) = 'RESET_TOKEN_LENGTH');
COMMIT;
/
