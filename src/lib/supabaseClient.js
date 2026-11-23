import { createClient } from '@supabase/supabase-js';
const url=import.meta.env.VITE_SUPABASE_URL;const key=import.meta.env.VITE_SUPABASE_ANON_KEY;
export const supabaseReady=Boolean(url&&key);
export const supabase=supabaseReady?createClient(url,key):null;
export async function getConnectionStatus(){if(!supabase)return{connected:false,label:'Local demo mode'};try{const{error}=await supabase.auth.getSession();return{connected:!error,label:error?'Needs configuration':'Supabase configured'};}catch{return{connected:false,label:'Connection unavailable'};}}