-- PostgreSQL schema for AI Voice Agent Platform (Phase 1)
-- Safe to run multiple times if the database is empty.

-- Enable UUID generation
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ENUM types
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'user_role') THEN
    CREATE TYPE user_role AS ENUM ('admin', 'user');
  END IF;

  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'subscription_status') THEN
    CREATE TYPE subscription_status AS ENUM ('active', 'canceled', 'trialing', 'past_due');
  END IF;

  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'agent_status') THEN
    CREATE TYPE agent_status AS ENUM ('draft', 'active', 'archived');
  END IF;

  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'call_direction') THEN
    CREATE TYPE call_direction AS ENUM ('inbound', 'outbound');
  END IF;

  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'call_status') THEN
    CREATE TYPE call_status AS ENUM ('completed', 'missed', 'failed', 'dropped', 'skipped_dnc');
  END IF;

  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'retry_status') THEN
    CREATE TYPE retry_status AS ENUM ('none', 'will_retry', 'final_attempt');
  END IF;
END$$;

-- 1. Core users, roles, billing, subscriptions

CREATE TABLE IF NOT EXISTS "user" (
  id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email             CITEXT UNIQUE NOT NULL,
  password_hash     TEXT NOT NULL,
  role              user_role NOT NULL DEFAULT 'user',
  is_active         BOOLEAN NOT NULL DEFAULT TRUE,
  created_at        TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at        TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS subscription_plan (
  id                          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  code                        TEXT UNIQUE NOT NULL,
  name                        TEXT NOT NULL,
  description                 TEXT,
  pricing_currency            TEXT NOT NULL,
  price_per_month             NUMERIC(12, 4) NOT NULL DEFAULT 0,
  included_credits_per_month  INTEGER NOT NULL DEFAULT 0,
  limits_json                 JSONB NOT NULL DEFAULT '{}'::JSONB,
  is_active                   BOOLEAN NOT NULL DEFAULT TRUE,
  created_at                  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at                  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS user_subscription (
  id                        UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id                   UUID NOT NULL REFERENCES "user"(id) ON DELETE CASCADE,
  subscription_plan_id      UUID NOT NULL REFERENCES subscription_plan(id),
  status                    subscription_status NOT NULL DEFAULT 'active',
  start_date                DATE NOT NULL,
  end_date                  DATE,
  renewal_date              DATE,
  is_auto_renew             BOOLEAN NOT NULL DEFAULT TRUE,
  current_credits           INTEGER NOT NULL DEFAULT 0,
  monthly_included_credits  INTEGER NOT NULL DEFAULT 0,
  external_subscription_id  TEXT,
  created_at                TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at                TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS user_billing_profile (
  id                    UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id               UUID NOT NULL UNIQUE REFERENCES "user"(id) ON DELETE CASCADE,
  billing_name          TEXT NOT NULL,
  company_name          TEXT,
  billing_address_json  JSONB NOT NULL DEFAULT '{}'::JSONB,
  tax_id                TEXT,
  payment_provider      TEXT,
  payment_customer_id   TEXT,
  created_at            TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at            TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS platform_settings (
  id                          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  concurrency_config_json     JSONB NOT NULL DEFAULT '{}'::JSONB,
  compliance_config_json      JSONB NOT NULL DEFAULT '{}'::JSONB,
  logging_defaults_json       JSONB NOT NULL DEFAULT '{}'::JSONB,
  billing_config_json         JSONB NOT NULL DEFAULT '{}'::JSONB,
  updated_by_user_id          UUID NOT NULL REFERENCES "user"(id),
  updated_at                  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 2. Agents and configuration

CREATE TABLE IF NOT EXISTS agent (
  id                   UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name                 TEXT NOT NULL,
  description          TEXT,
  purpose              TEXT,
  language             TEXT NOT NULL, -- e.g. 'en', 'hi', 'hinglish'
  status               agent_status NOT NULL DEFAULT 'draft',
  config_json          JSONB NOT NULL DEFAULT '{}'::JSONB,
  created_by_user_id   UUID NOT NULL REFERENCES "user"(id),
  created_at           TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at           TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS sample_agent_template (
  id                    UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name                  TEXT NOT NULL,
  description           TEXT,
  template_config_json  JSONB NOT NULL DEFAULT '{}'::JSONB,
  created_at            TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 3. DNC and outbound constraints

CREATE TABLE IF NOT EXISTS dnc_entry (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  phone_number  TEXT NOT NULL UNIQUE,
  reason        TEXT NOT NULL,
  source        TEXT NOT NULL CHECK (source IN ('manual', 'upload')),
  created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 4. Calls, logging, analytics

CREATE TABLE IF NOT EXISTS "call" (
  id                          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  agent_id                    UUID NOT NULL REFERENCES agent(id),
  direction                   call_direction NOT NULL,
  exotel_call_sid             TEXT,
  from_number                 TEXT NOT NULL,
  to_number                   TEXT NOT NULL,
  started_at                  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  ended_at                    TIMESTAMPTZ,
  status                      call_status NOT NULL,
  end_reason                  TEXT,
  attempt_index               INTEGER NOT NULL DEFAULT 0,
  max_attempts                INTEGER NOT NULL DEFAULT 1,
  retry_status                retry_status NOT NULL DEFAULT 'none',
  dnc_flag                    BOOLEAN NOT NULL DEFAULT FALSE,
  dnc_reason                  TEXT,
  cost_total                  NUMERIC(14, 6) NOT NULL DEFAULT 0,
  cost_breakdown_json         JSONB NOT NULL DEFAULT '{}'::JSONB,
  logging_config_snapshot_json JSONB NOT NULL DEFAULT '{}'::JSONB,
  transcript_json             JSONB,
  turns_json                  JSONB,
  summary_text                TEXT,
  intents_json                JSONB,
  sentiment                   TEXT,
  recording_url               TEXT,
  created_at                  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Helpful indexes
CREATE INDEX IF NOT EXISTS idx_user_email ON "user"(email);
CREATE INDEX IF NOT EXISTS idx_user_subscription_user ON user_subscription(user_id);
CREATE INDEX IF NOT EXISTS idx_agent_created_by_user ON agent(created_by_user_id);
CREATE INDEX IF NOT EXISTS idx_call_agent_id ON "call"(agent_id);
CREATE INDEX IF NOT EXISTS idx_call_started_at ON "call"(started_at);


