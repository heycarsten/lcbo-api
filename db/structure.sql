SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

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
-- Name: btree_gist; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS btree_gist WITH SCHEMA public;


--
-- Name: EXTENSION btree_gist; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION btree_gist IS 'support for indexing common datatypes in GiST';


--
-- Name: cube; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS cube WITH SCHEMA public;


--
-- Name: EXTENSION cube; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION cube IS 'data type for multidimensional cubes';


--
-- Name: earthdistance; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS earthdistance WITH SCHEMA public;


--
-- Name: EXTENSION earthdistance; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION earthdistance IS 'calculate great-circle distances on the surface of the Earth';


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
-- Name: intarray; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS intarray WITH SCHEMA public;


--
-- Name: EXTENSION intarray; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION intarray IS 'functions, operators, and index support for 1-D arrays of integers';


--
-- Name: ltree; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS ltree WITH SCHEMA public;


--
-- Name: EXTENSION ltree; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION ltree IS 'data type for hierarchical tree-like structures';


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


SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: ar_internal_metadata; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ar_internal_metadata (
    key character varying NOT NULL,
    value character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: categories; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.categories (
    id integer NOT NULL,
    name character varying(40) NOT NULL,
    lcbo_ref character varying(40) NOT NULL,
    parent_category_id integer,
    parent_category_ids integer[] DEFAULT '{}'::integer[] NOT NULL,
    is_dead boolean DEFAULT false NOT NULL,
    depth smallint NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    name_vectors tsvector
);


--
-- Name: categories_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.categories_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: categories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.categories_id_seq OWNED BY public.categories.id;


--
-- Name: crawl_events; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.crawl_events (
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

CREATE SEQUENCE public.crawl_events_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: crawl_events_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.crawl_events_id_seq OWNED BY public.crawl_events.id;


--
-- Name: crawls; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.crawls (
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

CREATE SEQUENCE public.crawls_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: crawls_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.crawls_id_seq OWNED BY public.crawls.id;


--
-- Name: emails; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.emails (
    id uuid DEFAULT public.uuid_generate_v1() NOT NULL,
    user_id uuid NOT NULL,
    address character varying(120) NOT NULL,
    is_verified boolean DEFAULT false NOT NULL,
    verification_secret character varying(36) NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: inventories; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.inventories (
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

CREATE SEQUENCE public.inventories_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: inventories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.inventories_id_seq OWNED BY public.inventories.id;


--
-- Name: keys; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.keys (
    id uuid DEFAULT public.uuid_generate_v1() NOT NULL,
    secret character varying(255) NOT NULL,
    label character varying(255),
    info text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    user_id uuid NOT NULL,
    domain character varying(100),
    kind integer DEFAULT 0,
    in_devmode boolean DEFAULT false NOT NULL,
    is_disabled boolean DEFAULT false NOT NULL
);


--
-- Name: plans; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.plans (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    stripe_uid character varying(45),
    title character varying(60),
    kind integer DEFAULT 0 NOT NULL,
    has_cors boolean DEFAULT false NOT NULL,
    has_ssl boolean DEFAULT false NOT NULL,
    has_upc_lookup boolean DEFAULT false NOT NULL,
    has_upc_value boolean DEFAULT false NOT NULL,
    has_history boolean DEFAULT false NOT NULL,
    request_pool_size integer DEFAULT 65000 NOT NULL,
    fee_in_cents integer DEFAULT 0 NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: producers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.producers (
    id integer NOT NULL,
    name character varying(80) NOT NULL,
    lcbo_ref character varying(100) NOT NULL,
    is_dead boolean DEFAULT false NOT NULL,
    is_ocb boolean DEFAULT false NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    name_vectors tsvector
);


--
-- Name: producers_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.producers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: producers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.producers_id_seq OWNED BY public.producers.id;


--
-- Name: products; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.products (
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
    package_unit_volume_in_milliliters integer DEFAULT 0,
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
    tag_vectors tsvector,
    upc bigint,
    scc bigint,
    style_flavour character varying(255),
    style_body character varying(255),
    value_added_promotion_ends_on date,
    data_source integer DEFAULT 0,
    producer_id integer,
    category_ids integer[] DEFAULT '{}'::integer[] NOT NULL,
    category character varying(140),
    is_ocb boolean DEFAULT false NOT NULL,
    catalog_refs integer[] DEFAULT '{}'::integer[] NOT NULL
);


--
-- Name: products_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.products_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: products_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.products_id_seq OWNED BY public.products.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    version character varying(255) NOT NULL
);


--
-- Name: stores; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.stores (
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
    tag_vectors tsvector,
    kind character varying(255),
    landmark_name character varying(255)
);


--
-- Name: stores_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.stores_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: stores_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.stores_id_seq OWNED BY public.stores.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    id uuid DEFAULT public.uuid_generate_v1() NOT NULL,
    name character varying(255),
    email character varying(120),
    password_digest character varying(60) NOT NULL,
    verification_secret character varying(36) NOT NULL,
    auth_secret character varying(36) NOT NULL,
    last_seen_ip character varying(255),
    last_seen_at timestamp without time zone,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    plan_id uuid,
    is_disabled boolean DEFAULT false NOT NULL
);


--
-- Name: categories id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.categories ALTER COLUMN id SET DEFAULT nextval('public.categories_id_seq'::regclass);


--
-- Name: crawl_events id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.crawl_events ALTER COLUMN id SET DEFAULT nextval('public.crawl_events_id_seq'::regclass);


--
-- Name: crawls id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.crawls ALTER COLUMN id SET DEFAULT nextval('public.crawls_id_seq'::regclass);


--
-- Name: inventories id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.inventories ALTER COLUMN id SET DEFAULT nextval('public.inventories_id_seq'::regclass);


--
-- Name: producers id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.producers ALTER COLUMN id SET DEFAULT nextval('public.producers_id_seq'::regclass);


--
-- Name: products id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.products ALTER COLUMN id SET DEFAULT nextval('public.products_id_seq'::regclass);


--
-- Name: stores id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stores ALTER COLUMN id SET DEFAULT nextval('public.stores_id_seq'::regclass);


--
-- Name: ar_internal_metadata ar_internal_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ar_internal_metadata
    ADD CONSTRAINT ar_internal_metadata_pkey PRIMARY KEY (key);


--
-- Name: categories categories_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.categories
    ADD CONSTRAINT categories_pkey PRIMARY KEY (id);


--
-- Name: crawl_events crawl_events_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.crawl_events
    ADD CONSTRAINT crawl_events_pkey PRIMARY KEY (id);


--
-- Name: crawls crawls_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.crawls
    ADD CONSTRAINT crawls_pkey PRIMARY KEY (id);


--
-- Name: emails emails_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.emails
    ADD CONSTRAINT emails_pkey PRIMARY KEY (id);


--
-- Name: inventories inventories_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.inventories
    ADD CONSTRAINT inventories_pkey PRIMARY KEY (id);


--
-- Name: keys keys_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.keys
    ADD CONSTRAINT keys_pkey PRIMARY KEY (id);


--
-- Name: plans plans_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.plans
    ADD CONSTRAINT plans_pkey PRIMARY KEY (id);


--
-- Name: producers producers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.producers
    ADD CONSTRAINT producers_pkey PRIMARY KEY (id);


--
-- Name: products products_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_pkey PRIMARY KEY (id);


--
-- Name: stores stores_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stores
    ADD CONSTRAINT stores_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: crawl_events_crawl_id_created_at_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX crawl_events_crawl_id_created_at_index ON public.crawl_events USING btree (crawl_id, created_at);


--
-- Name: crawls_created_at_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX crawls_created_at_index ON public.crawls USING btree (created_at);


--
-- Name: crawls_state_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX crawls_state_index ON public.crawls USING btree (state);


--
-- Name: crawls_total_inventories_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX crawls_total_inventories_index ON public.crawls USING btree (total_inventories);


--
-- Name: crawls_total_product_inventory_count_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX crawls_total_product_inventory_count_index ON public.crawls USING btree (total_product_inventory_count);


--
-- Name: crawls_total_product_inventory_price_in_cents_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX crawls_total_product_inventory_price_in_cents_index ON public.crawls USING btree (total_product_inventory_price_in_cents);


--
-- Name: crawls_total_product_inventory_volume_in_milliliters_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX crawls_total_product_inventory_volume_in_milliliters_index ON public.crawls USING btree (total_product_inventory_volume_in_milliliters);


--
-- Name: crawls_total_products_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX crawls_total_products_index ON public.crawls USING btree (total_products);


--
-- Name: crawls_total_stores_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX crawls_total_stores_index ON public.crawls USING btree (total_stores);


--
-- Name: crawls_updated_at_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX crawls_updated_at_index ON public.crawls USING btree (updated_at);


--
-- Name: index_categories_on_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_categories_on_created_at ON public.categories USING btree (created_at);


--
-- Name: index_categories_on_depth; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_categories_on_depth ON public.categories USING btree (depth);


--
-- Name: index_categories_on_is_dead; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_categories_on_is_dead ON public.categories USING btree (is_dead);


--
-- Name: index_categories_on_lcbo_ref; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_categories_on_lcbo_ref ON public.categories USING btree (lcbo_ref);


--
-- Name: index_categories_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_categories_on_name ON public.categories USING btree (name);


--
-- Name: index_categories_on_name_vectors; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_categories_on_name_vectors ON public.categories USING gin (name_vectors);


--
-- Name: index_categories_on_parent_category_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_categories_on_parent_category_id ON public.categories USING btree (parent_category_id);


--
-- Name: index_categories_on_parent_category_ids; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_categories_on_parent_category_ids ON public.categories USING gin (parent_category_ids);


--
-- Name: index_categories_on_updated_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_categories_on_updated_at ON public.categories USING btree (updated_at);


--
-- Name: index_emails_on_address; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_emails_on_address ON public.emails USING btree (address);


--
-- Name: index_emails_on_is_verified_and_address; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_emails_on_is_verified_and_address ON public.emails USING btree (is_verified, address);


--
-- Name: index_emails_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_emails_on_user_id ON public.emails USING btree (user_id);


--
-- Name: index_inventories_on_product_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_inventories_on_product_id ON public.inventories USING btree (product_id);


--
-- Name: index_inventories_on_product_id_and_store_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_inventories_on_product_id_and_store_id ON public.inventories USING btree (product_id, store_id);


--
-- Name: index_inventories_on_quantity; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_inventories_on_quantity ON public.inventories USING btree (quantity);


--
-- Name: index_inventories_on_store_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_inventories_on_store_id ON public.inventories USING btree (store_id);


--
-- Name: index_keys_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_keys_on_user_id ON public.keys USING btree (user_id);


--
-- Name: index_plans_on_is_active; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_plans_on_is_active ON public.plans USING btree (is_active);


--
-- Name: index_producers_on_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_producers_on_created_at ON public.producers USING btree (created_at);


--
-- Name: index_producers_on_is_dead; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_producers_on_is_dead ON public.producers USING btree (is_dead);


--
-- Name: index_producers_on_is_ocb; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_producers_on_is_ocb ON public.producers USING btree (is_ocb);


--
-- Name: index_producers_on_lcbo_ref; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_producers_on_lcbo_ref ON public.producers USING btree (lcbo_ref);


--
-- Name: index_producers_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_producers_on_name ON public.producers USING btree (name);


--
-- Name: index_producers_on_name_vectors; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_producers_on_name_vectors ON public.producers USING gin (name_vectors);


--
-- Name: index_producers_on_updated_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_producers_on_updated_at ON public.producers USING btree (updated_at);


--
-- Name: index_products_on_catalog_refs; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_products_on_catalog_refs ON public.products USING gin (catalog_refs);


--
-- Name: index_products_on_category_ids; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_products_on_category_ids ON public.products USING gin (category_ids);


--
-- Name: index_products_on_is_dead_and_inventory_volume_in_milliliters; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_products_on_is_dead_and_inventory_volume_in_milliliters ON public.products USING btree (is_dead, inventory_volume_in_milliliters);


--
-- Name: index_products_on_is_ocb; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_products_on_is_ocb ON public.products USING btree (is_ocb);


--
-- Name: index_products_on_producer_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_products_on_producer_id ON public.products USING btree (producer_id);


--
-- Name: index_products_on_tag_vectors; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_products_on_tag_vectors ON public.products USING gin (tag_vectors);


--
-- Name: index_products_on_upc; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_products_on_upc ON public.products USING btree (upc);


--
-- Name: index_products_on_value_added_promotion_ends_on; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_products_on_value_added_promotion_ends_on ON public.products USING btree (value_added_promotion_ends_on);


--
-- Name: index_stores_on_tag_vectors; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_stores_on_tag_vectors ON public.stores USING gin (tag_vectors);


--
-- Name: index_users_on_is_disabled; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_is_disabled ON public.users USING btree (is_disabled);


--
-- Name: inventories_is_dead_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX inventories_is_dead_index ON public.inventories USING btree (is_dead);


--
-- Name: products_alcohol_content_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX products_alcohol_content_index ON public.products USING btree (alcohol_content);


--
-- Name: products_bonus_reward_miles_ends_on_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX products_bonus_reward_miles_ends_on_index ON public.products USING btree (bonus_reward_miles_ends_on);


--
-- Name: products_bonus_reward_miles_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX products_bonus_reward_miles_index ON public.products USING btree (bonus_reward_miles);


--
-- Name: products_clearance_sale_savings_in_cents_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX products_clearance_sale_savings_in_cents_index ON public.products USING btree (clearance_sale_savings_in_cents);


--
-- Name: products_created_at_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX products_created_at_index ON public.products USING btree (created_at);


--
-- Name: products_has_value_added_promotion_has_limited_time_offer_has_b; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX products_has_value_added_promotion_has_limited_time_offer_has_b ON public.products USING btree (has_value_added_promotion, has_limited_time_offer, has_bonus_reward_miles, is_seasonal, is_vqa, is_kosher);


--
-- Name: products_inventory_count_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX products_inventory_count_index ON public.products USING btree (inventory_count);


--
-- Name: products_inventory_price_in_cents_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX products_inventory_price_in_cents_index ON public.products USING btree (inventory_price_in_cents);


--
-- Name: products_inventory_volume_in_milliliters_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX products_inventory_volume_in_milliliters_index ON public.products USING btree (inventory_volume_in_milliliters);


--
-- Name: products_is_dead_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX products_is_dead_index ON public.products USING btree (is_dead);


--
-- Name: products_is_discontinued_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX products_is_discontinued_index ON public.products USING btree (is_discontinued);


--
-- Name: products_limited_time_offer_ends_on_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX products_limited_time_offer_ends_on_index ON public.products USING btree (limited_time_offer_ends_on);


--
-- Name: products_limited_time_offer_savings_in_cents_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX products_limited_time_offer_savings_in_cents_index ON public.products USING btree (limited_time_offer_savings_in_cents);


--
-- Name: products_package_unit_volume_in_milliliters_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX products_package_unit_volume_in_milliliters_index ON public.products USING btree (package_unit_volume_in_milliliters);


--
-- Name: products_price_in_cents_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX products_price_in_cents_index ON public.products USING btree (price_in_cents);


--
-- Name: products_price_per_liter_in_cents_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX products_price_per_liter_in_cents_index ON public.products USING btree (price_per_liter_in_cents);


--
-- Name: products_price_per_liter_of_alcohol_in_cents_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX products_price_per_liter_of_alcohol_in_cents_index ON public.products USING btree (price_per_liter_of_alcohol_in_cents);


--
-- Name: products_primary_category_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX products_primary_category_index ON public.products USING btree (primary_category);


--
-- Name: products_regular_price_in_cents_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX products_regular_price_in_cents_index ON public.products USING btree (regular_price_in_cents);


--
-- Name: products_released_on_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX products_released_on_index ON public.products USING btree (released_on);


--
-- Name: products_secondary_category_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX products_secondary_category_index ON public.products USING btree (secondary_category);


--
-- Name: products_stock_type_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX products_stock_type_index ON public.products USING btree (stock_type);


--
-- Name: products_style_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX products_style_index ON public.products USING btree (style);


--
-- Name: products_sugar_in_grams_per_liter_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX products_sugar_in_grams_per_liter_index ON public.products USING btree (sugar_in_grams_per_liter);


--
-- Name: products_tags_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX products_tags_index ON public.products USING gin (to_tsvector('simple'::regconfig, (COALESCE(tags, ''::character varying))::text));


--
-- Name: products_tertiary_category_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX products_tertiary_category_index ON public.products USING btree (tertiary_category);


--
-- Name: products_updated_at_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX products_updated_at_index ON public.products USING btree (updated_at);


--
-- Name: products_varietal_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX products_varietal_index ON public.products USING btree (varietal);


--
-- Name: products_volume_in_milliliters_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX products_volume_in_milliliters_index ON public.products USING btree (volume_in_milliliters);


--
-- Name: stores_created_at_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX stores_created_at_index ON public.stores USING btree (created_at);


--
-- Name: stores_has_wheelchair_accessability_has_bilingual_services_has_; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX stores_has_wheelchair_accessability_has_bilingual_services_has_ ON public.stores USING btree (has_wheelchair_accessability, has_bilingual_services, has_product_consultant, has_tasting_bar, has_beer_cold_room, has_special_occasion_permits, has_vintages_corner, has_parking, has_transit_access);


--
-- Name: stores_inventory_count_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX stores_inventory_count_index ON public.stores USING btree (inventory_count);


--
-- Name: stores_inventory_price_in_cents_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX stores_inventory_price_in_cents_index ON public.stores USING btree (inventory_price_in_cents);


--
-- Name: stores_inventory_volume_in_milliliters_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX stores_inventory_volume_in_milliliters_index ON public.stores USING btree (inventory_volume_in_milliliters);


--
-- Name: stores_is_dead_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX stores_is_dead_index ON public.stores USING btree (is_dead);


--
-- Name: stores_products_count_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX stores_products_count_index ON public.stores USING btree (products_count);


--
-- Name: stores_tags_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX stores_tags_index ON public.stores USING gin (to_tsvector('simple'::regconfig, (COALESCE(tags, ''::character varying))::text));


--
-- Name: stores_updated_at_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX stores_updated_at_index ON public.stores USING btree (updated_at);


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX unique_schema_migrations ON public.schema_migrations USING btree (version);


--
-- Name: categories categories_tsvectorupdate; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER categories_tsvectorupdate BEFORE INSERT OR UPDATE ON public.categories FOR EACH ROW EXECUTE PROCEDURE tsvector_update_trigger('name_vectors', 'pg_catalog.simple', 'name');


--
-- Name: producers producers_tsvectorupdate; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER producers_tsvectorupdate BEFORE INSERT OR UPDATE ON public.producers FOR EACH ROW EXECUTE PROCEDURE tsvector_update_trigger('name_vectors', 'pg_catalog.simple', 'name');


--
-- Name: products products_tsvectorupdate; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER products_tsvectorupdate BEFORE INSERT OR UPDATE ON public.products FOR EACH ROW EXECUTE PROCEDURE tsvector_update_trigger('tag_vectors', 'pg_catalog.simple', 'tags');


--
-- Name: stores stores_tsvectorupdate; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER stores_tsvectorupdate BEFORE INSERT OR UPDATE ON public.stores FOR EACH ROW EXECUTE PROCEDURE tsvector_update_trigger('tag_vectors', 'pg_catalog.simple', 'tags');


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user", public;

INSERT INTO "schema_migrations" (version) VALUES
('20140613161248'),
('20140613173103'),
('20140613182304'),
('20140616233032'),
('20140621143738'),
('20140621151939'),
('20140625021830'),
('20140627024053'),
('20140706215519'),
('20140707151430'),
('20140707173828'),
('20140709004216'),
('20140712015328'),
('20140714201631'),
('20140714202224'),
('20140717031508'),
('20140801013002'),
('20141110021113'),
('20141110023249'),
('20141110171340'),
('20141111022512'),
('20141111023631'),
('20150211195035'),
('20150211202803'),
('20150212011542'),
('20150212015705'),
('20150212040211'),
('20150212141949'),
('20150213020057'),
('20150213173003'),
('20150213203700'),
('20150214035627'),
('20150924205712');


