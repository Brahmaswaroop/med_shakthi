-- Create wishlist table for storing user wishlists
CREATE TABLE IF NOT EXISTS wishlist (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    product_id TEXT NOT NULL,
    product_name TEXT NOT NULL,
    product_price DECIMAL(10, 2) NOT NULL,
    product_image TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id, product_id)
);

-- Create index for faster queries
CREATE INDEX IF NOT EXISTS idx_wishlist_user_id ON wishlist(user_id);
CREATE INDEX IF NOT EXISTS idx_wishlist_product_id ON wishlist(product_id);

-- Enable Row Level Security
ALTER TABLE wishlist ENABLE ROW LEVEL SECURITY;

-- Create policy: Users can only see their own wishlist items
CREATE POLICY "Users can view their own wishlist"
    ON wishlist FOR SELECT
    USING (auth.uid() = user_id);

-- Create policy: Users can insert their own wishlist items
CREATE POLICY "Users can insert their own wishlist"
    ON wishlist FOR INSERT
    WITH CHECK (auth.uid() = user_id);

-- Create policy: Users can delete their own wishlist items
CREATE POLICY "Users can delete their own wishlist"
    ON wishlist FOR DELETE
    USING (auth.uid() = user_id);

-- Create policy: Users can update their own wishlist items
CREATE POLICY "Users can update their own wishlist"
    ON wishlist FOR UPDATE
    USING (auth.uid() = user_id);
