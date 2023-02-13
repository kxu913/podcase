-- Table: public.rssfeed

-- DROP TABLE IF EXISTS public.rssfeed;

CREATE TABLE IF NOT EXISTS public.rssfeed
(
    id text COLLATE pg_catalog."default" NOT NULL,
    title text COLLATE pg_catalog."default",
    subtitle text COLLATE pg_catalog."default",
    summary text COLLATE pg_catalog."default",
    author text COLLATE pg_catalog."default",
    email text COLLATE pg_catalog."default",
    image text COLLATE pg_catalog."default",
    url text COLLATE pg_catalog."default" NOT NULL,
    CONSTRAINT rssfeed_pkey PRIMARY KEY (id)
);

ALTER TABLE rssfeed REPLICA IDENTITY FULL