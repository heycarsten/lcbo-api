--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


--
-- Name: btree_gin; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS btree_gin WITH SCHEMA public;


--
-- Name: EXTENSION btree_gin; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION btree_gin IS 'support for indexing common datatypes in GIN';


--
-- Name: fuzzystrmatch; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS fuzzystrmatch WITH SCHEMA public;


--
-- Name: EXTENSION fuzzystrmatch; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION fuzzystrmatch IS 'determine similarities and distance between strings';


--
-- Name: hstore; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS hstore WITH SCHEMA public;


--
-- Name: EXTENSION hstore; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION hstore IS 'data type for storing sets of (key, value) pairs';


--
-- Name: pg_trgm; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_trgm WITH SCHEMA public;


--
-- Name: EXTENSION pg_trgm; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pg_trgm IS 'text similarity measurement and index searching based on trigrams';


--
-- Name: tsearch2; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS tsearch2 WITH SCHEMA public;


--
-- Name: EXTENSION tsearch2; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION tsearch2 IS 'compatibility package for pre-8.3 text search functions';


--
-- Name: unaccent; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS unaccent WITH SCHEMA public;


--
-- Name: EXTENSION unaccent; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION unaccent IS 'text search dictionary that removes accents';


--
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA public;


--
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: crawl_events; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE crawl_events (
    id integer NOT NULL,
    crawl_id integer,
    level character varying(25),
    message text,
    payload text,
    created_at timestamp without time zone NOT NULL
);


--
-- Name: crawl_events_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE crawl_events_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: crawl_events_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE crawl_events_id_seq OWNED BY crawl_events.id;


--
-- Name: crawls; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE crawls (
    id integer NOT NULL,
    crawl_event_id integer,
    state character varying(20),
    task character varying(60),
    total_products integer DEFAULT 0,
    total_stores integer DEFAULT 0,
    total_inventories integer DEFAULT 0,
    total_product_inventory_count bigint DEFAULT 0,
    total_product_inventory_volume_in_milliliters bigint DEFAULT 0,
    total_product_inventory_price_in_cents bigint DEFAULT 0,
    total_jobs integer DEFAULT 0,
    total_finished_jobs integer DEFAULT 0,
    store_ids text,
    product_ids text,
    added_product_ids text,
    added_store_ids text,
    removed_product_ids text,
    removed_store_ids text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: crawls_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE crawls_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: crawls_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE crawls_id_seq OWNED BY crawls.id;


--
-- Name: emails; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE emails (
    id uuid DEFAULT uuid_generate_v1() NOT NULL,
    user_id uuid NOT NULL,
    address character varying(120) NOT NULL,
    is_verified boolean DEFAULT false NOT NULL,
    verification_secret character varying(36) NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: inventories; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE inventories (
    product_id integer NOT NULL,
    store_id integer NOT NULL,
    crawl_id integer,
    is_dead boolean DEFAULT false,
    quantity integer DEFAULT 0,
    reported_on date,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    id integer NOT NULL
);


--
-- Name: inventories_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE inventories_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: inventories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE inventories_id_seq OWNED BY inventories.id;


--
-- Name: keys; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE keys (
    id uuid DEFAULT uuid_generate_v1() NOT NULL,
    user_id integer,
    secret character varying(255) NOT NULL,
    label character varying(255),
    info text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: products; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE products (
    id integer NOT NULL,
    crawl_id integer,
    is_dead boolean DEFAULT false,
    name character varying(100),
    tags character varying(380),
    is_discontinued boolean DEFAULT false,
    price_in_cents integer DEFAULT 0,
    regular_price_in_cents integer DEFAULT 0,
    limited_time_offer_savings_in_cents integer DEFAULT 0,
    limited_time_offer_ends_on date,
    bonus_reward_miles smallint DEFAULT 0,
    bonus_reward_miles_ends_on date,
    stock_type character varying(10),
    primary_category character varying(60),
    secondary_category character varying(60),
    origin character varying(60),
    package character varying(32),
    package_unit_type character varying(20),
    package_unit_volume_in_milliliters smallint DEFAULT 0,
    total_package_units smallint DEFAULT 0,
    total_package_volume_in_milliliters integer DEFAULT 0,
    volume_in_milliliters integer DEFAULT 0,
    alcohol_content smallint DEFAULT 0,
    price_per_liter_of_alcohol_in_cents integer DEFAULT 0,
    price_per_liter_in_cents integer DEFAULT 0,
    inventory_count bigint DEFAULT 0,
    inventory_volume_in_milliliters bigint DEFAULT 0,
    inventory_price_in_cents bigint DEFAULT 0,
    sugar_content character varying(100),
    producer_name character varying(80),
    released_on date,
    has_value_added_promotion boolean DEFAULT false,
    has_limited_time_offer boolean DEFAULT false,
    has_bonus_reward_miles boolean DEFAULT false,
    is_seasonal boolean DEFAULT false,
    is_vqa boolean DEFAULT false,
    is_kosher boolean DEFAULT false,
    value_added_promotion_description text,
    description text,
    serving_suggestion text,
    tasting_note text,
    updated_at timestamp without time zone NOT NULL,
    created_at timestamp without time zone NOT NULL,
    image_thumb_url character varying(120),
    image_url character varying(120),
    varietal character varying(100),
    style character varying(100),
    tertiary_category character varying(60),
    sugar_in_grams_per_liter smallint DEFAULT 0,
    clearance_sale_savings_in_cents integer DEFAULT 0,
    has_clearance_sale boolean DEFAULT false,
    tag_vectors pg_catalog.tsvector,
    upc character varying(255),
    scc character varying(255),
    style_flavour character varying(255),
    style_body character varying(255),
    value_added_promotion_ends_on date,
    data_source integer DEFAULT 0
);


--
-- Name: products_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE products_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: products_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE products_id_seq OWNED BY products.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE schema_migrations (
    version character varying(255) NOT NULL
);


--
-- Name: stores; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE stores (
    id integer NOT NULL,
    crawl_id integer,
    is_dead boolean DEFAULT false,
    name character varying(50),
    tags character varying(380),
    address_line_1 character varying(40),
    address_line_2 character varying(40),
    city character varying(25),
    postal_code character(6),
    telephone character(14),
    fax character(14),
    latitude real NOT NULL,
    longitude real NOT NULL,
    latrad real NOT NULL,
    lngrad real NOT NULL,
    products_count integer DEFAULT 0,
    inventory_count bigint DEFAULT 0,
    inventory_price_in_cents bigint DEFAULT 0,
    inventory_volume_in_milliliters bigint DEFAULT 0,
    has_wheelchair_accessability boolean DEFAULT false,
    has_bilingual_services boolean DEFAULT false,
    has_product_consultant boolean DEFAULT false,
    has_tasting_bar boolean DEFAULT false,
    has_beer_cold_room boolean DEFAULT false,
    has_special_occasion_permits boolean DEFAULT false,
    has_vintages_corner boolean DEFAULT false,
    has_parking boolean DEFAULT false,
    has_transit_access boolean DEFAULT false,
    sunday_open smallint,
    sunday_close smallint,
    monday_open smallint,
    monday_close smallint,
    tuesday_open smallint,
    tuesday_close smallint,
    wednesday_open smallint,
    wednesday_close smallint,
    thursday_open smallint,
    thursday_close smallint,
    friday_open smallint,
    friday_close smallint,
    saturday_open smallint,
    saturday_close smallint,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    tag_vectors pg_catalog.tsvector,
    kind character varying(255),
    landmark_name character varying(255)
);


--
-- Name: stores_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE stores_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: stores_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE stores_id_seq OWNED BY stores.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE users (
    id uuid DEFAULT uuid_generate_v1() NOT NULL,
    name character varying(255),
    email character varying(120),
    password_digest character varying(60) NOT NULL,
    verification_secret character varying(36) NOT NULL,
    auth_secret character varying(36) NOT NULL,
    last_seen_ip character varying(255),
    last_seen_at timestamp without time zone,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY crawl_events ALTER COLUMN id SET DEFAULT nextval('crawl_events_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY crawls ALTER COLUMN id SET DEFAULT nextval('crawls_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY inventories ALTER COLUMN id SET DEFAULT nextval('inventories_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY products ALTER COLUMN id SET DEFAULT nextval('products_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY stores ALTER COLUMN id SET DEFAULT nextval('stores_id_seq'::regclass);


--
-- Name: crawl_events_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY crawl_events
    ADD CONSTRAINT crawl_events_pkey PRIMARY KEY (id);


--
-- Name: crawls_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY crawls
    ADD CONSTRAINT crawls_pkey PRIMARY KEY (id);


--
-- Name: emails_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY emails
    ADD CONSTRAINT emails_pkey PRIMARY KEY (id);


--
-- Name: inventories_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY inventories
    ADD CONSTRAINT inventories_pkey PRIMARY KEY (id);


--
-- Name: keys_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY keys
    ADD CONSTRAINT keys_pkey PRIMARY KEY (id);


--
-- Name: products_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY products
    ADD CONSTRAINT products_pkey PRIMARY KEY (id);


--
-- Name: stores_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY stores
    ADD CONSTRAINT stores_pkey PRIMARY KEY (id);


--
-- Name: users_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: crawl_events_crawl_id_created_at_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX crawl_events_crawl_id_created_at_index ON crawl_events USING btree (crawl_id, created_at);


--
-- Name: crawls_created_at_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX crawls_created_at_index ON crawls USING btree (created_at);


--
-- Name: crawls_state_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX crawls_state_index ON crawls USING btree (state);


--
-- Name: crawls_total_inventories_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX crawls_total_inventories_index ON crawls USING btree (total_inventories);


--
-- Name: crawls_total_product_inventory_count_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX crawls_total_product_inventory_count_index ON crawls USING btree (total_product_inventory_count);


--
-- Name: crawls_total_product_inventory_price_in_cents_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX crawls_total_product_inventory_price_in_cents_index ON crawls USING btree (total_product_inventory_price_in_cents);


--
-- Name: crawls_total_product_inventory_volume_in_milliliters_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX crawls_total_product_inventory_volume_in_milliliters_index ON crawls USING btree (total_product_inventory_volume_in_milliliters);


--
-- Name: crawls_total_products_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX crawls_total_products_index ON crawls USING btree (total_products);


--
-- Name: crawls_total_stores_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX crawls_total_stores_index ON crawls USING btree (total_stores);


--
-- Name: crawls_updated_at_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX crawls_updated_at_index ON crawls USING btree (updated_at);


--
-- Name: index_emails_on_address; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_emails_on_address ON emails USING btree (address);


--
-- Name: index_emails_on_is_verified_and_address; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_emails_on_is_verified_and_address ON emails USING btree (is_verified, address);


--
-- Name: index_emails_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_emails_on_user_id ON emails USING btree (user_id);


--
-- Name: index_inventories_on_product_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_inventories_on_product_id ON inventories USING btree (product_id);


--
-- Name: index_inventories_on_product_id_and_store_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_inventories_on_product_id_and_store_id ON inventories USING btree (product_id, store_id);


--
-- Name: index_inventories_on_quantity; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_inventories_on_quantity ON inventories USING btree (quantity);


--
-- Name: index_inventories_on_store_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_inventories_on_store_id ON inventories USING btree (store_id);


--
-- Name: index_keys_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_keys_on_user_id ON keys USING btree (user_id);


--
-- Name: index_products_on_is_dead_and_inventory_volume_in_milliliters; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_products_on_is_dead_and_inventory_volume_in_milliliters ON products USING btree (is_dead, inventory_volume_in_milliliters);


--
-- Name: index_products_on_tag_vectors; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_products_on_tag_vectors ON products USING gin (tag_vectors);


--
-- Name: index_products_on_value_added_promotion_ends_on; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_products_on_value_added_promotion_ends_on ON products USING btree (value_added_promotion_ends_on);


--
-- Name: index_stores_on_tag_vectors; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_stores_on_tag_vectors ON stores USING gin (tag_vectors);


--
-- Name: inventories_is_dead_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX inventories_is_dead_index ON inventories USING btree (is_dead);


--
-- Name: products_alcohol_content_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX products_alcohol_content_index ON products USING btree (alcohol_content);


--
-- Name: products_bonus_reward_miles_ends_on_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX products_bonus_reward_miles_ends_on_index ON products USING btree (bonus_reward_miles_ends_on);


--
-- Name: products_bonus_reward_miles_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX products_bonus_reward_miles_index ON products USING btree (bonus_reward_miles);


--
-- Name: products_clearance_sale_savings_in_cents_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX products_clearance_sale_savings_in_cents_index ON products USING btree (clearance_sale_savings_in_cents);


--
-- Name: products_created_at_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX products_created_at_index ON products USING btree (created_at);


--
-- Name: products_has_value_added_promotion_has_limited_time_offer_has_b; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX products_has_value_added_promotion_has_limited_time_offer_has_b ON products USING btree (has_value_added_promotion, has_limited_time_offer, has_bonus_reward_miles, is_seasonal, is_vqa, is_kosher);


--
-- Name: products_inventory_count_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX products_inventory_count_index ON products USING btree (inventory_count);


--
-- Name: products_inventory_price_in_cents_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX products_inventory_price_in_cents_index ON products USING btree (inventory_price_in_cents);


--
-- Name: products_inventory_volume_in_milliliters_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX products_inventory_volume_in_milliliters_index ON products USING btree (inventory_volume_in_milliliters);


--
-- Name: products_is_dead_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX products_is_dead_index ON products USING btree (is_dead);


--
-- Name: products_is_discontinued_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX products_is_discontinued_index ON products USING btree (is_discontinued);


--
-- Name: products_limited_time_offer_ends_on_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX products_limited_time_offer_ends_on_index ON products USING btree (limited_time_offer_ends_on);


--
-- Name: products_limited_time_offer_savings_in_cents_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX products_limited_time_offer_savings_in_cents_index ON products USING btree (limited_time_offer_savings_in_cents);


--
-- Name: products_package_unit_volume_in_milliliters_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX products_package_unit_volume_in_milliliters_index ON products USING btree (package_unit_volume_in_milliliters);


--
-- Name: products_price_in_cents_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX products_price_in_cents_index ON products USING btree (price_in_cents);


--
-- Name: products_price_per_liter_in_cents_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX products_price_per_liter_in_cents_index ON products USING btree (price_per_liter_in_cents);


--
-- Name: products_price_per_liter_of_alcohol_in_cents_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX products_price_per_liter_of_alcohol_in_cents_index ON products USING btree (price_per_liter_of_alcohol_in_cents);


--
-- Name: products_primary_category_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX products_primary_category_index ON products USING btree (primary_category);


--
-- Name: products_regular_price_in_cents_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX products_regular_price_in_cents_index ON products USING btree (regular_price_in_cents);


--
-- Name: products_released_on_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX products_released_on_index ON products USING btree (released_on);


--
-- Name: products_secondary_category_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX products_secondary_category_index ON products USING btree (secondary_category);


--
-- Name: products_stock_type_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX products_stock_type_index ON products USING btree (stock_type);


--
-- Name: products_style_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX products_style_index ON products USING btree (style);


--
-- Name: products_sugar_in_grams_per_liter_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX products_sugar_in_grams_per_liter_index ON products USING btree (sugar_in_grams_per_liter);


--
-- Name: products_tags_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX products_tags_index ON products USING gin (to_tsvector('simple'::regconfig, (COALESCE(tags, ''::character varying))::text));


--
-- Name: products_tertiary_category_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX products_tertiary_category_index ON products USING btree (tertiary_category);


--
-- Name: products_updated_at_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX products_updated_at_index ON products USING btree (updated_at);


--
-- Name: products_varietal_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX products_varietal_index ON products USING btree (varietal);


--
-- Name: products_volume_in_milliliters_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX products_volume_in_milliliters_index ON products USING btree (volume_in_milliliters);


--
-- Name: stores_created_at_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX stores_created_at_index ON stores USING btree (created_at);


--
-- Name: stores_has_wheelchair_accessability_has_bilingual_services_has_; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX stores_has_wheelchair_accessability_has_bilingual_services_has_ ON stores USING btree (has_wheelchair_accessability, has_bilingual_services, has_product_consultant, has_tasting_bar, has_beer_cold_room, has_special_occasion_permits, has_vintages_corner, has_parking, has_transit_access);


--
-- Name: stores_inventory_count_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX stores_inventory_count_index ON stores USING btree (inventory_count);


--
-- Name: stores_inventory_price_in_cents_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX stores_inventory_price_in_cents_index ON stores USING btree (inventory_price_in_cents);


--
-- Name: stores_inventory_volume_in_milliliters_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX stores_inventory_volume_in_milliliters_index ON stores USING btree (inventory_volume_in_milliliters);


--
-- Name: stores_is_dead_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX stores_is_dead_index ON stores USING btree (is_dead);


--
-- Name: stores_products_count_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX stores_products_count_index ON stores USING btree (products_count);


--
-- Name: stores_tags_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX stores_tags_index ON stores USING gin (to_tsvector('simple'::regconfig, (COALESCE(tags, ''::character varying))::text));


--
-- Name: stores_updated_at_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX stores_updated_at_index ON stores USING btree (updated_at);


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX unique_schema_migrations ON schema_migrations USING btree (version);


--
-- Name: products_tsvectorupdate; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER products_tsvectorupdate BEFORE INSERT OR UPDATE ON products FOR EACH ROW EXECUTE PROCEDURE tsvector_update_trigger('tag_vectors', 'pg_catalog.simple', 'tags');


--
-- Name: stores_tsvectorupdate; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER stores_tsvectorupdate BEFORE INSERT OR UPDATE ON stores FOR EACH ROW EXECUTE PROCEDURE tsvector_update_trigger('tag_vectors', 'pg_catalog.simple', 'tags');


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user",public;

INSERT INTO schema_migrations (version) VALUES ('20140613161248');

INSERT INTO schema_migrations (version) VALUES ('20140613173103');

INSERT INTO schema_migrations (version) VALUES ('20140613182304');

INSERT INTO schema_migrations (version) VALUES ('20140616233032');

INSERT INTO schema_migrations (version) VALUES ('20140621143738');

INSERT INTO schema_migrations (version) VALUES ('20140621151939');

INSERT INTO schema_migrations (version) VALUES ('20140625021830');

INSERT INTO schema_migrations (version) VALUES ('20140627024053');

INSERT INTO schema_migrations (version) VALUES ('20140706215519');

INSERT INTO schema_migrations (version) VALUES ('20140707151430');

INSERT INTO schema_migrations (version) VALUES ('20140707173828');

INSERT INTO schema_migrations (version) VALUES ('20140709004216');

INSERT INTO schema_migrations (version) VALUES ('20140712015328');

INSERT INTO schema_migrations (version) VALUES ('20140714201631');

INSERT INTO schema_migrations (version) VALUES ('20140714202224');

INSERT INTO schema_migrations (version) VALUES ('20140717031508');

