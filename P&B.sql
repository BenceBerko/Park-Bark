-- Park&Bark -- 

--user amount--

SELECT
COUNT (DISTINCT userid)
FROM
pandb.user_fixed;

--car amount--

SELECT
COUNT (DISTINCT carid)
FROM
pandb.car_fixed;


--car payment--

SELECT
COUNT (DISTINCT paymentid)
FROM
pandb.payment_fixed;

--all payment--

SELECT
SUM (amount)
FROM
pandb.payment_fixed;


--lista a top user-ekről--


SELECT 
    pandb.user_fixed.userid, 
    pandb.user_fixed.emailaddress,
    pandb.user_fixed.phonenumber,
    SUM (pandb.payment_fixed.amount) AS osszes_koltes,
    COUNT (pandb.payment_fixed.amount) AS osszes_fizetés
FROM 
    pandb.user_fixed
JOIN 
    pandb.car_fixed ON pandb.user_fixed.userid = pandb.car_fixed.userid
JOIN 
    pandb.payment_fixed ON pandb.car_fixed.carid = pandb.payment_fixed.carid
GROUP BY 
    pandb.user_fixed.userid,
    pandb.user_fixed.emailaddress,
    pandb.user_fixed.phonenumber
ORDER BY 
    osszes_koltes DESC;


--user/auto/usertype--

SELECT 
    user_fixed.userid, 
    pandb.user_fixed.emailaddress,
    pandb.user_fixed.phonenumber,
    COUNT(car_fixed.carid) AS osszes_auto
FROM 
    pandb.user_fixed
JOIN 
    pandb.car_fixed ON user_fixed.userid = car_fixed.userid
    WHERE 
    user_fixed.role = 'customer'
GROUP BY 
    user_fixed.userid,
    pandb.user_fixed.emailaddress,
    pandb.user_fixed.phonenumber
ORDER BY 
    osszes_auto DESC;


SELECT 
    user_fixed.userid, 
    COUNT(car_fixed.carid) AS osszes_auto
FROM 
    pandb.user_fixed
JOIN 
    pandb.car_fixed ON user_fixed.userid = car_fixed.userid
    WHERE 
    user_fixed.role = 'driver'
GROUP BY 
    user_fixed.userid
ORDER BY 
    osszes_auto DESC;


SELECT 
    user_fixed.userid, 
    COUNT(car_fixed.carid) AS osszes_auto
FROM 
    pandb.user_fixed
JOIN 
    pandb.car_fixed ON user_fixed.userid = car_fixed.userid
    WHERE 
    user_fixed.role = 'admin'
GROUP BY 
    user_fixed.userid
ORDER BY 
    osszes_auto DESC;


SELECT 
    user_fixed.userid, 
    COUNT(car_fixed.carid) AS osszes_auto
FROM 
    pandb.user_fixed
JOIN 
    pandb.car_fixed ON user_fixed.userid = car_fixed.userid
    WHERE 
    user_fixed.role = 'reception'
GROUP BY 
    user_fixed.userid
ORDER BY 
    osszes_auto DESC;


--Árbevétel/usertype

SELECT 
    pandb.user_fixed.usertype,
    SUM (pandb.payment_fixed.amount::bigint) AS bevetel_usertype
FROM 
    pandb.user_fixed
JOIN 
    pandb.car_fixed ON pandb.car_fixed.userid = pandb.user_fixed.userid
JOIN 
    pandb.payment_fixed ON pandb.car_fixed.carid = pandb.payment_fixed.carid
GROUP BY 
     pandb.user_fixed.usertype
ORDER BY 
    bevetel_usertype DESC;


SELECT 
    pandb.user_fixed.usertype,
    pandb.user_fixed.role,
    SUM (pandb.payment_fixed.amount::bigint) AS bevetel_role
FROM 
    pandb.user_fixed
JOIN 
    pandb.car_fixed ON pandb.car_fixed.userid = pandb.user_fixed.userid
JOIN 
    pandb.payment_fixed ON pandb.car_fixed.carid = pandb.payment_fixed.carid
GROUP BY 
    pandb.user_fixed.usertype,
     pandb.user_fixed.role
ORDER BY 
    bevetel_role DESC;


--Dátum szerint parkoló autókk száma

SELECT 
    nap::date AS datum,
    (SELECT COUNT(*) 
     FROM pandb.car_fixed c 
     WHERE nap::date >= c."from"::date 
       AND nap::date <= c."to"::date) AS bent_allo_autok_szama
FROM (
    SELECT generate_series(
        '2024-01-01'::date, 
        '2026-03-22'::date, 
        '1 day'::interval
    ) AS nap
) naptar_sorozat
WHERE 
    (SELECT COUNT(*) FROM pandb.car_fixed c WHERE nap::date >= c."from"::date AND nap::date <= c."to"::date) > 0
ORDER BY 
    datum DESC;




SELECT 
    nap::date AS datum,
    (SELECT COUNT(*) 
     FROM pandb.car_fixed c 
     WHERE nap::date >= c."from"::date 
       AND nap::date <= c."to"::date
       AND c.status != 'parkingCancelled'
    ) AS bent_allo_autok_szama
FROM (
    SELECT generate_series(
        '2024-01-01'::date, 
        '2026-03-22'::date, 
        '1 day'::interval
    ) AS nap
) naptar_sorozat
WHERE 
    (SELECT COUNT(*) 
     FROM pandb.car_fixed c 
     WHERE nap::date >= c."from"::date 
       AND nap::date <= c."to"::date
       AND c.status != 'parkingCancelled'
    ) > 0
ORDER BY 
    datum DESC;




SELECT 
    nap::date AS datum,
    (SELECT COUNT(*) 
     FROM pandb.car_fixed c 
     WHERE nap::date >= c."from"::date 
       AND nap::date <= c."to"::date
       AND c.status != 'parkingCancelled'
    ) AS bent_allo_autok_szama,
    (SELECT SUM(p.amount) 
     FROM pandb.payment_fixed p 
     WHERE p.paydate::date = nap::date 
       AND p.status != 'cancelled'
    ) AS napi_bevetel_osszesen
FROM (
    SELECT generate_series(
        '2024-01-01'::date, 
        '2026-03-22'::date, 
        '1 day'::interval
    ) AS nap
) naptar_sorozat
WHERE 
    (SELECT COUNT(*) FROM pandb.car_fixed c WHERE nap::date >= c."from"::date AND nap::date <= c."to"::date AND c.status != 'parkingCancelled') > 0
    OR 
    (SELECT SUM(p.amount) FROM pandb.payment_fixed p WHERE p.paydate::date = nap::date AND p.status != 'cancelled') > 0
ORDER BY 
    datum DESC;



--Fizetett tranzakciók száma
SELECT
COUNT (DISTINCT pandb.payment_fixed.paymentid)
FROM
    pandb.payment_fixed
WHERE 
    pandb.payment_fixed.status != 'cancelled';


--service alapú lekérdezés az árbevételre--
SELECT 
    p.service AS szolgaltatas_tipusa,
    COUNT(p.paymentid) AS tranzakciok_szama,
    SUM(p.amount) AS tiszta_arbevetel
FROM 
    pandb.payment_fixed p
WHERE 
    p.service IS NOT NULL 
    AND p.service != ''
    AND p.status != 'cancelled'
    AND p.amount > 0
GROUP BY 
    p.service
ORDER BY 
    tiszta_arbevetel DESC;SELECT 
    p.service AS szolgaltatas_tipusa,
    COUNT(p.paymentid) AS tranzakciok_szama,
    SUM(p.amount) AS tiszta_arbevetel
FROM 
    pandb.payment_fixed p
WHERE 
    p.service IS NOT NULL 
    AND p.service != ''
    AND p.status != 'cancelled'
    AND p.amount > 0
GROUP BY 
    p.service
ORDER BY 
    tiszta_arbevetel DESC;




--Indor-outdoor + service alapú évjárat elosztás
SELECT 
    CASE 
        WHEN LEFT(c.license, 2) IN ('AA', 'AB') THEN '2022'
        WHEN LEFT(c.license, 2) IN ('AC', 'AD', 'AE') THEN '2023'
        WHEN LEFT(c.license, 2) IN ('AF', 'AG', 'AI', 'AH') THEN '2024'
        WHEN LEFT(c.license, 2) IN ('AJ', 'AK', 'AL') THEN '2025'
        WHEN LEFT(c.license, 2) IN ('AM', 'AN', 'AO') THEN '2026'
        WHEN LEFT(c.license, 1) = 'T' THEN '2021'
        WHEN LEFT(c.license, 1) = 'S' THEN '2020'
        WHEN LEFT(c.license, 1) = 'R' THEN '2018'
        WHEN LEFT(c.license, 1) = 'P' THEN '2016'
        WHEN LEFT(c.license, 1) = 'N' THEN '2014'
        WHEN LEFT(c.license, 1) = 'M' THEN '2011'
        WHEN LEFT(c.license, 1) = 'L' THEN '2007'
        WHEN LEFT(c.license, 1) = 'K' THEN '2005'
        WHEN LEFT(c.license, 1) = 'J' THEN '2003'
        WHEN LEFT(c.license, 1) = 'I' THEN '2002'
        WHEN LEFT(c.license, 1) = 'H' THEN '2001'
        WHEN LEFT(c.license, 1) = 'G' THEN '1999'
        WHEN LEFT(c.license, 1) = 'F' THEN '1996'
        WHEN LEFT(c.license, 1) = 'E' THEN '1994'
        WHEN LEFT(c.license, 1) = 'D' THEN '1992'
        WHEN LEFT(c.license, 1) IN ('A', 'B', 'C') THEN '1990-1991'
        ELSE 'Egyéb/Külföldi'
    END AS auto_becsult_evjarata,
    COUNT(CASE WHEN c.parkingtype = 'outdoor' THEN 1 END) AS "Outdoor (db)",
    COUNT(CASE WHEN c.parkingtype = 'indoor' THEN 1 END) AS "Indoor (db)",
    SUM(CASE WHEN p.service = 'parking' THEN p.amount ELSE 0 END) AS bev_parking,
    SUM(CASE WHEN p.service = 'carWash' THEN p.amount ELSE 0 END) AS bev_carWash,
    SUM(CASE WHEN p.service = 'bagWrapping' THEN p.amount ELSE 0 END) AS bev_bagWrapping,
    SUM(CASE WHEN p.service = 'windshieldRepair' THEN p.amount ELSE 0 END) AS bev_windshieldRepair,
    SUM(CASE WHEN p.service = 'other' THEN p.amount ELSE 0 END) AS bev_other,
    COUNT(p.paymentid) AS osszes_tranzakcio,
    SUM(p.amount) AS havi_szumma_bevetel
FROM 
    pandb.car_fixed c
JOIN 
    pandb.payment_fixed p ON c.carid = p.carid
WHERE
    p.service IS NOT NULL 
    AND p.service != ''
    AND p.status != 'cancelled'
    AND p.amount > 0
    AND p.service = 'paid'
GROUP BY 
    auto_becsult_evjarata
ORDER BY 
    auto_becsult_evjarata DESC;

--Parkolt napok szánm összesen

SELECT 
    SUM(c."to"::date - c."from"::date) AS napok_szama
FROM 
    pandb.car_fixed c
WHERE 
    c."from" IS NOT NULL 
    AND c."to" IS NOT NULL
    AND c."to"::date >= c."from"::date;

--Havi lebontás usertype / bevétel

SELECT 
    DATE_TRUNC('month', NULLIF(u.createdat, '')::timestamp)::date AS honap,
    COUNT(DISTINCT u.userid) AS osszes_regisztracio,
    COUNT(DISTINCT CASE WHEN u.usertype = 'employee' THEN u.userid END) AS employee_reg_db,
    COUNT(DISTINCT CASE WHEN u.usertype = 'guest' THEN u.userid END) AS guest_reg_db,
    COUNT(DISTINCT CASE WHEN u.usertype = 'registered' THEN u.userid END) AS registered_reg_db,
    SUM(CASE WHEN u.usertype = 'employee' AND p.status = 'paid' THEN p.amount ELSE 0 END) AS employee_bevetel,
    SUM(CASE WHEN u.usertype = 'guest' AND p.status = 'paid' THEN p.amount ELSE 0 END) AS guest_bevetel,
    SUM(CASE WHEN u.usertype = 'registered' AND p.status = 'paid' THEN p.amount ELSE 0 END) AS registered_bevetel,
    SUM(CASE WHEN p.status = 'paid' THEN p.amount ELSE 0 END) AS havi_szumma_bevetel
FROM 
    pandb.user_fixed u
LEFT JOIN 
    pandb.car_fixed c ON u.userid = c.userid
LEFT JOIN 
    pandb.payment_fixed p ON c.carid = p.carid
WHERE 
    u.createdat IS NOT NULL 
    AND u.createdat != ''
    AND LENGTH(u.createdat) >= 10
GROUP BY 
    1
ORDER BY 
    honap DESC;






