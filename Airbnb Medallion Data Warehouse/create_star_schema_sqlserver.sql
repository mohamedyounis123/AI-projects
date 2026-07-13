CREATE DATABASE AirbnbDWH;  
USE AirbnbDWH;
GO

IF OBJECT_ID('fact_listings', 'U') IS NOT NULL DROP TABLE fact_listings;
IF OBJECT_ID('dim_location', 'U') IS NOT NULL DROP TABLE dim_location;
IF OBJECT_ID('dim_room_type', 'U') IS NOT NULL DROP TABLE dim_room_type;
IF OBJECT_ID('dim_day_type', 'U') IS NOT NULL DROP TABLE dim_day_type;
IF OBJECT_ID('dim_price_category', 'U') IS NOT NULL DROP TABLE dim_price_category;

-- ------------------------------------------------------------
-- DIMENSION: dim_location
-- ------------------------------------------------------------
CREATE TABLE dim_location (
    location_id     INT IDENTITY(1,1) PRIMARY KEY,
    city            NVARCHAR(100) NOT NULL,
    district        NVARCHAR(100),
    state           NVARCHAR(100),
    country_code    NVARCHAR(10),
    country_name    NVARCHAR(100),
    CONSTRAINT UQ_dim_location UNIQUE (city, district, state, country_code)
);

-- ------------------------------------------------------------
-- DIMENSION: dim_room_type
-- ------------------------------------------------------------
CREATE TABLE dim_room_type (
    room_type_id    INT IDENTITY(1,1) PRIMARY KEY,
    room_type       NVARCHAR(100) NOT NULL UNIQUE
);

-- ------------------------------------------------------------
-- DIMENSION: dim_day_type
-- ------------------------------------------------------------
CREATE TABLE dim_day_type (
    day_type_id     INT IDENTITY(1,1) PRIMARY KEY,
    day_type        NVARCHAR(50) NOT NULL UNIQUE,
    is_weekend      BIT NOT NULL
);

-- ------------------------------------------------------------
-- DIMENSION: dim_price_category
-- ------------------------------------------------------------
CREATE TABLE dim_price_category (
    price_category_id   INT IDENTITY(1,1) PRIMARY KEY,
    price_category       NVARCHAR(50) NOT NULL UNIQUE
);

-- ------------------------------------------------------------
-- FACT: fact_listings
-- ------------------------------------------------------------
CREATE TABLE fact_listings (
    record_id                           INT PRIMARY KEY,
    location_id                         INT NOT NULL,
    room_type_id                        INT NOT NULL,
    day_type_id                         INT NOT NULL,
    price_category_id                   INT NOT NULL,

    listing_title                       NVARCHAR(500),
    price_total                         FLOAT NOT NULL,
    is_shared_room                      BIT,
    is_private_room                     BIT,
    max_guests                          INT,
    bedrooms                            INT,
    is_superhost                        BIT,
    is_business_listing                 BIT,
    cleanliness_score                   FLOAT,
    guest_satisfaction_score            FLOAT,
    longitude                           FLOAT,
    latitude                            FLOAT,

    missing_bedrooms                    BIT,
    missing_max_guests                  BIT,
    missing_cleanliness_score           BIT,
    missing_guest_satisfaction_score    BIT,

    price_per_bedroom                   FLOAT,
    price_per_guest                     FLOAT,
    price_per_person                    FLOAT,
    listing_title_length                INT,
    listing_quality_score               FLOAT,
    host_score                          INT,

    silver_processed_time               NVARCHAR(50),
    source_system                       NVARCHAR(50),

    CONSTRAINT FK_fact_location       FOREIGN KEY (location_id)       REFERENCES dim_location(location_id),
    CONSTRAINT FK_fact_room_type      FOREIGN KEY (room_type_id)      REFERENCES dim_room_type(room_type_id),
    CONSTRAINT FK_fact_day_type       FOREIGN KEY (day_type_id)       REFERENCES dim_day_type(day_type_id),
    CONSTRAINT FK_fact_price_category FOREIGN KEY (price_category_id) REFERENCES dim_price_category(price_category_id)
);

-- ------------------------------------------------------------
-- INDEXES
-- ------------------------------------------------------------
CREATE INDEX idx_fact_location  ON fact_listings(location_id);
CREATE INDEX idx_fact_room_type ON fact_listings(room_type_id);
CREATE INDEX idx_fact_day_type  ON fact_listings(day_type_id);
CREATE INDEX idx_fact_price_cat ON fact_listings(price_category_id);