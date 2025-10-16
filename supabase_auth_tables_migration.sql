-- =====================================================
-- Supabase Migration: Authentication Tables
-- Run this in Supabase SQL Editor
-- =====================================================

-- 1. Create api_keys table for storing API keys per user
CREATE TABLE IF NOT EXISTS api_keys (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  key TEXT NOT NULL UNIQUE,
  name TEXT,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create indexes on api_keys
CREATE INDEX IF NOT EXISTS idx_api_keys_user_id ON api_keys(user_id);
CREATE INDEX IF NOT EXISTS idx_api_keys_key ON api_keys(key) WHERE is_active = true;

-- Add comment
COMMENT ON TABLE api_keys IS 'Stores API keys for scanner app authentication';

-- =====================================================

-- 2. Create device_logins table for tracking login history
CREATE TABLE IF NOT EXISTS device_logins (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  device_name TEXT,
  api_key TEXT,
  logged_in_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create index on device_logins
CREATE INDEX IF NOT EXISTS idx_device_logins_user_id ON device_logins(user_id);
CREATE INDEX IF NOT EXISTS idx_device_logins_logged_in_at ON device_logins(logged_in_at DESC);

-- Add comment
COMMENT ON TABLE device_logins IS 'Tracks scanner app device login history';

-- =====================================================

-- 3. Enable Row Level Security
ALTER TABLE api_keys ENABLE ROW LEVEL SECURITY;
ALTER TABLE device_logins ENABLE ROW LEVEL SECURITY;

-- =====================================================

-- 4. RLS Policies for api_keys
DROP POLICY IF EXISTS "Users can view their own API keys" ON api_keys;
CREATE POLICY "Users can view their own API keys"
  ON api_keys FOR SELECT
  USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can insert their own API keys" ON api_keys;
CREATE POLICY "Users can insert their own API keys"
  ON api_keys FOR INSERT
  WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can update their own API keys" ON api_keys;
CREATE POLICY "Users can update their own API keys"
  ON api_keys FOR UPDATE
  USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can delete their own API keys" ON api_keys;
CREATE POLICY "Users can delete their own API keys"
  ON api_keys FOR DELETE
  USING (auth.uid() = user_id);

-- =====================================================

-- 5. RLS Policies for device_logins
DROP POLICY IF EXISTS "Users can view their own device logins" ON device_logins;
CREATE POLICY "Users can view their own device logins"
  ON device_logins FOR SELECT
  USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can insert their own device logins" ON device_logins;
CREATE POLICY "Users can insert their own device logins"
  ON device_logins FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- =====================================================

-- 6. Grant necessary permissions (run as service_role)
-- These allow the API routes to access the tables
GRANT ALL ON api_keys TO service_role;
GRANT ALL ON device_logins TO service_role;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO service_role;

-- =====================================================

-- 7. Verify tables were created
SELECT 
  table_name,
  (SELECT COUNT(*) FROM information_schema.columns WHERE table_name = t.table_name) as column_count
FROM information_schema.tables t
WHERE table_schema = 'public' 
  AND table_name IN ('api_keys', 'device_logins')
ORDER BY table_name;

-- =====================================================
-- DONE! Tables created successfully.
-- 
-- Next steps:
-- 1. Deploy backend API to Vercel (if not already done)
-- 2. Test login API with curl or Postman
-- 3. Run Flutter app to test integration
-- =====================================================

