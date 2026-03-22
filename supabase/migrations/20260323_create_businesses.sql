-- Migration to create businesses table
CREATE TABLE IF NOT EXISTS public.businesses (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    description TEXT,
    latitude DOUBLE PRECISION NOT NULL,
    longitude DOUBLE PRECISION NOT NULL,
    category TEXT NOT NULL,
    image_url TEXT,
    contact_phone TEXT,
    contact_email TEXT,
    website TEXT,
    status TEXT DEFAULT 'pending',
    is_featured BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE public.businesses ENABLE ROW LEVEL SECURITY;

-- Public read access
CREATE POLICY "Allow public read access to businesses"
    ON public.businesses FOR SELECT
    USING (status = 'approved');

-- Admin access (placeholder for now)
CREATE POLICY "Allow authenticated insert to businesses"
    ON public.businesses FOR INSERT
    WITH CHECK (true);
