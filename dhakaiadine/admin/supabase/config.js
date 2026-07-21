import { createClient } from 'https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2/+esm';

const SUPABASE_URL = 'https://olrcszjhhnitlepiqvvb.supabase.co';
const SUPABASE_ANON_KEY = 'sb_secret_LJp2gIWjjxFcX9JoNpMv3A_hE9aOJMa';

export const supabase = createClient(SUPABASE_URL, SUPABASE_ANON_KEY);
