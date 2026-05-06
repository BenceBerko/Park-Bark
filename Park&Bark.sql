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


Dátum alapú 

