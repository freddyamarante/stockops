
SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

CREATE EXTENSION IF NOT EXISTS "pgsodium" WITH SCHEMA "pgsodium";

CREATE EXTENSION IF NOT EXISTS "pg_graphql" WITH SCHEMA "graphql";

CREATE EXTENSION IF NOT EXISTS "pg_stat_statements" WITH SCHEMA "extensions";

CREATE EXTENSION IF NOT EXISTS "pgcrypto" WITH SCHEMA "extensions";

CREATE EXTENSION IF NOT EXISTS "pgjwt" WITH SCHEMA "extensions";

CREATE EXTENSION IF NOT EXISTS "supabase_vault" WITH SCHEMA "vault";

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA "extensions";

CREATE OR REPLACE FUNCTION "public"."handle_new_user"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$begin
  insert into public."Users" (user_id, email, ci, address, first_name, last_name)
  values (new.id, new.raw_user_meta_data->>'email', new.raw_user_meta_data->>'ci', new.raw_user_meta_data->>'address', new.raw_user_meta_data->>'first_name', new.raw_user_meta_data->>'last_name');
  return new;
end;
$$;

ALTER FUNCTION "public"."handle_new_user"() OWNER TO "postgres";

SET default_tablespace = '';

SET default_table_access_method = "heap";

CREATE TABLE IF NOT EXISTS "public"."InvoiceItems" (
    "uid" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "invoice_uid" "uuid" NOT NULL,
    "product_uid" "uuid" NOT NULL,
    "quantity" integer DEFAULT 1 NOT NULL
);

ALTER TABLE "public"."InvoiceItems" OWNER TO "postgres";

CREATE TABLE IF NOT EXISTS "public"."Invoices" (
    "uid" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "type" character varying NOT NULL,
    "date" "date" NOT NULL,
    "store_uid" "uuid" NOT NULL,
    "supplier_uid" "uuid"
);

ALTER TABLE "public"."Invoices" OWNER TO "postgres";

CREATE TABLE IF NOT EXISTS "public"."Products" (
    "uid" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "name" character varying NOT NULL,
    "description" "text",
    "category" character varying NOT NULL,
    "price" numeric NOT NULL,
    "quantity_in_stock" integer,
    "expiration_date" "date",
    "unit_of_measurement" character varying NOT NULL,
    "store_uid" "uuid" NOT NULL
);

ALTER TABLE "public"."Products" OWNER TO "postgres";

CREATE TABLE IF NOT EXISTS "public"."Stores" (
    "uid" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "name" character varying NOT NULL,
    "rif" character varying NOT NULL,
    "address" character varying NOT NULL,
    "owner_user_uid" "uuid" NOT NULL
);

ALTER TABLE "public"."Stores" OWNER TO "postgres";

CREATE TABLE IF NOT EXISTS "public"."Suppliers" (
    "uid" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "contact_info" "text",
    "name" character varying NOT NULL
);

ALTER TABLE "public"."Suppliers" OWNER TO "postgres";

CREATE TABLE IF NOT EXISTS "public"."UserStores" (
    "uid" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "user_uid" "uuid" NOT NULL,
    "store_uid" "uuid" NOT NULL,
    "roles" character varying[] NOT NULL
);

ALTER TABLE "public"."UserStores" OWNER TO "postgres";

CREATE TABLE IF NOT EXISTS "public"."Users" (
    "user_id" "uuid" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "ci" character varying NOT NULL,
    "address" character varying NOT NULL,
    "first_name" character varying NOT NULL,
    "last_name" character varying NOT NULL,
    "email" character varying NOT NULL
);

ALTER TABLE "public"."Users" OWNER TO "postgres";

ALTER TABLE ONLY "public"."InvoiceItems"
    ADD CONSTRAINT "InvoiceItems_pkey" PRIMARY KEY ("uid");

ALTER TABLE ONLY "public"."InvoiceItems"
    ADD CONSTRAINT "InvoiceItems_product_uid_key" UNIQUE ("product_uid");

ALTER TABLE ONLY "public"."Invoices"
    ADD CONSTRAINT "Invoices_pkey" PRIMARY KEY ("uid");

ALTER TABLE ONLY "public"."Products"
    ADD CONSTRAINT "Products_pkey" PRIMARY KEY ("uid");

ALTER TABLE ONLY "public"."Stores"
    ADD CONSTRAINT "Stores_pkey" PRIMARY KEY ("uid");

ALTER TABLE ONLY "public"."Stores"
    ADD CONSTRAINT "Stores_rif_key" UNIQUE ("rif");

ALTER TABLE ONLY "public"."Suppliers"
    ADD CONSTRAINT "Suppliers_pkey" PRIMARY KEY ("uid");

ALTER TABLE ONLY "public"."UserStores"
    ADD CONSTRAINT "UserStores_pkey" PRIMARY KEY ("uid");

ALTER TABLE ONLY "public"."Users"
    ADD CONSTRAINT "Users_ci_key" UNIQUE ("ci");

ALTER TABLE ONLY "public"."Users"
    ADD CONSTRAINT "Users_pkey" PRIMARY KEY ("user_id");

ALTER TABLE ONLY "public"."InvoiceItems"
    ADD CONSTRAINT "InvoiceItems_invoice_uid_fkey" FOREIGN KEY ("invoice_uid") REFERENCES "public"."Invoices"("uid") ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE ONLY "public"."InvoiceItems"
    ADD CONSTRAINT "InvoiceItems_product_uid_fkey" FOREIGN KEY ("product_uid") REFERENCES "public"."Products"("uid") ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE ONLY "public"."Invoices"
    ADD CONSTRAINT "Invoices_store_uid_fkey" FOREIGN KEY ("store_uid") REFERENCES "public"."Stores"("uid") ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE ONLY "public"."Invoices"
    ADD CONSTRAINT "Invoices_supplier_uid_fkey" FOREIGN KEY ("supplier_uid") REFERENCES "public"."Suppliers"("uid") ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE ONLY "public"."Products"
    ADD CONSTRAINT "Products_store_uid_fkey" FOREIGN KEY ("store_uid") REFERENCES "public"."Stores"("uid") ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE ONLY "public"."Stores"
    ADD CONSTRAINT "Stores_owner_user_uid_fkey" FOREIGN KEY ("owner_user_uid") REFERENCES "public"."Users"("user_id") ON UPDATE CASCADE ON DELETE SET NULL;

ALTER TABLE ONLY "public"."UserStores"
    ADD CONSTRAINT "UserStores_store_uid_fkey" FOREIGN KEY ("store_uid") REFERENCES "public"."Stores"("uid") ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE ONLY "public"."UserStores"
    ADD CONSTRAINT "UserStores_user_uid_fkey" FOREIGN KEY ("user_uid") REFERENCES "public"."Users"("user_id") ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE ONLY "public"."Users"
    ADD CONSTRAINT "Users_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;

CREATE POLICY "Enable insert for users based on user_id" ON "public"."Users" FOR INSERT WITH CHECK (("auth"."uid"() = "user_id"));

CREATE POLICY "Enable read access for all users" ON "public"."Users" FOR SELECT USING (true);

CREATE POLICY "Enable update for users based on ID" ON "public"."Users" FOR UPDATE USING (("auth"."uid"() = "user_id"));

ALTER TABLE "public"."InvoiceItems" ENABLE ROW LEVEL SECURITY;

ALTER TABLE "public"."Invoices" ENABLE ROW LEVEL SECURITY;

ALTER TABLE "public"."Products" ENABLE ROW LEVEL SECURITY;

ALTER TABLE "public"."Stores" ENABLE ROW LEVEL SECURITY;

ALTER TABLE "public"."Suppliers" ENABLE ROW LEVEL SECURITY;

ALTER TABLE "public"."UserStores" ENABLE ROW LEVEL SECURITY;

ALTER TABLE "public"."Users" ENABLE ROW LEVEL SECURITY;

REVOKE USAGE ON SCHEMA "public" FROM PUBLIC;
GRANT USAGE ON SCHEMA "public" TO "postgres";
GRANT USAGE ON SCHEMA "public" TO "anon";
GRANT USAGE ON SCHEMA "public" TO "authenticated";
GRANT USAGE ON SCHEMA "public" TO "service_role";

GRANT ALL ON FUNCTION "public"."handle_new_user"() TO "anon";
GRANT ALL ON FUNCTION "public"."handle_new_user"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."handle_new_user"() TO "service_role";

GRANT ALL ON TABLE "public"."InvoiceItems" TO "anon";
GRANT ALL ON TABLE "public"."InvoiceItems" TO "authenticated";
GRANT ALL ON TABLE "public"."InvoiceItems" TO "service_role";

GRANT ALL ON TABLE "public"."Invoices" TO "anon";
GRANT ALL ON TABLE "public"."Invoices" TO "authenticated";
GRANT ALL ON TABLE "public"."Invoices" TO "service_role";

GRANT ALL ON TABLE "public"."Products" TO "anon";
GRANT ALL ON TABLE "public"."Products" TO "authenticated";
GRANT ALL ON TABLE "public"."Products" TO "service_role";

GRANT ALL ON TABLE "public"."Stores" TO "anon";
GRANT ALL ON TABLE "public"."Stores" TO "authenticated";
GRANT ALL ON TABLE "public"."Stores" TO "service_role";

GRANT ALL ON TABLE "public"."Suppliers" TO "anon";
GRANT ALL ON TABLE "public"."Suppliers" TO "authenticated";
GRANT ALL ON TABLE "public"."Suppliers" TO "service_role";

GRANT ALL ON TABLE "public"."UserStores" TO "anon";
GRANT ALL ON TABLE "public"."UserStores" TO "authenticated";
GRANT ALL ON TABLE "public"."UserStores" TO "service_role";

GRANT ALL ON TABLE "public"."Users" TO "anon";
GRANT ALL ON TABLE "public"."Users" TO "authenticated";
GRANT ALL ON TABLE "public"."Users" TO "service_role";

ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES  TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES  TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES  TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES  TO "service_role";

ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS  TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS  TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS  TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS  TO "service_role";

ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES  TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES  TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES  TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES  TO "service_role";

RESET ALL;
