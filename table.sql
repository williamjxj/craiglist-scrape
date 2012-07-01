use craig;

/*
cid INT UNSIGNED AUTO_INCREMENT NOT NULL PRIMARY KEY,
sid int UNSIGNED AUTO_INCREMENT NOT NULL PRIMARY KEY,
cid INT UNSIGNED AUTO_INCREMENT NOT NULL PRIMARY KEY,
iid INT UNSIGNED AUTO_INCREMENT NOT NULL PRIMARY KEY,
*/

DROP TABLE IF EXISTS craigslist_country_state;
CREATE TABLE craigslist_country_state
(
    sname  VARCHAR(100) NOT NULL,
    surl VARCHAR(255) NOT NULL,
    area VARCHAR(100) NULL,
    selected enum('Y', 'N') not null default 'N',
    sdate  DATETIME,
    PRIMARY KEY (surl)
);

DROP TABLE IF EXISTS craigslist_city;
CREATE TABLE craigslist_city
(
    cname  VARCHAR(100) NOT NULL,
    curl VARCHAR(255) NOT NULL,
    area1 VARCHAR(100) NULL,
    area2 VARCHAR(100) NULL,
    selected enum('Y', 'N') not null default 'N',
    cdate  DATETIME,
    PRIMARY KEY (curl)
);

DROP TABLE IF EXISTS craigslist_category;
CREATE TABLE craigslist_category
(
    cname  VARCHAR(100) NOT NULL,
    curl VARCHAR(255) NOT NULL,
    selected enum('Y', 'N') not null default 'N',
    cdate  DATETIME,
    PRIMARY KEY (curl)
);

DROP TABLE IF EXISTS craigslist_item;
CREATE TABLE craigslist_item
(
    iname  VARCHAR(100) NOT NULL,
    iurl VARCHAR(255) NOT NULL,
	category VARCHAR(100) NOT NULL,
    selected enum('Y', 'N') not null default 'N',
    idate  DATETIME,
    PRIMARY KEY (iurl)
);


DROP TABLE IF EXISTS craigslist_topic;
CREATE TABLE craigslist_topic
(
    url VARCHAR(100) NOT NULL,
    keywords  VARCHAR(255) NOT NULL,
    relevant  VARCHAR(200) NOT NULL,
	location VARCHAR(100) NULL,
	item_url varchar(100) NOT NULL,    
    item  VARCHAR(100) NOT NULL,
    post_time DATETIME,
    email VARCHAR(255) NOT NULL,
	phone VARCHAR(30) NULL,
	web VARCHAR(255) NULL,
    city  VARCHAR(100) NOT NULL,
    category  VARCHAR(100) NOT NULL,
    date  DATETIME,
    primary key (url)
);

DROP TABLE IF EXISTS craigslist_usjobs;
CREATE TABLE craigslist_usjobs
(
	id int unsigned not null auto_increment primary key,
    url VARCHAR(100) NOT NULL,
    keywords  VARCHAR(255) NOT NULL,
    relevant  VARCHAR(200) NOT NULL,
	location VARCHAR(100) NULL,
	item_url varchar(100) NOT NULL,    
    item  VARCHAR(100) NOT NULL,
    post_time DATETIME,
    email VARCHAR(255) NOT NULL,
	phone VARCHAR(30) NULL,
	web VARCHAR(255) NULL,
    city  VARCHAR(100) NOT NULL,
    category  VARCHAR(100) NOT NULL,
    date  DATETIME,
    unique (url)
);

