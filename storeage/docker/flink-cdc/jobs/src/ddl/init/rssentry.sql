-- Table: public.rssentry

-- DROP TABLE IF EXISTS public.rssentry;

CREATE TABLE IF NOT EXISTS public.rssentry
(
    feed_id text COLLATE pg_catalog."default" NOT NULL,
    type text COLLATE pg_catalog."default",
    title text COLLATE pg_catalog."default",
    url text COLLATE pg_catalog."default" NOT NULL,
    summary text COLLATE pg_catalog."default",
    image text COLLATE pg_catalog."default",
    author text COLLATE pg_catalog."default",
    duration text COLLATE pg_catalog."default",
    publish_at timestamp without time zone,
    CONSTRAINT rssentry_pkey PRIMARY KEY (url)
);

ALTER TABLE rssentry REPLICA IDENTITY FULL