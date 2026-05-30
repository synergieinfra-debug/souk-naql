-- ============================================================
--  سوق النقل واللوجستيك — Schéma Supabase
--  À coller dans : Supabase  →  SQL Editor  →  New query  →  Run
-- ============================================================

-- 1) UTILISATEURS -------------------------------------------------
create table if not exists public.users_naql (
  id           uuid primary key default gen_random_uuid(),
  created_at   timestamptz default now(),
  nom          text not null,
  telephone    text not null,
  region       text,
  type_user    text default 'client',   -- client | transporteur | societe
  premium      boolean default false,
  nb_annonces  integer default 0,
  note         numeric
);
create unique index if not exists users_naql_tel_idx on public.users_naql (telephone);

-- 2) ANNONCES -----------------------------------------------------
create table if not exists public.annonces_naql (
  id             uuid primary key default gen_random_uuid(),
  created_at     timestamptz default now(),
  user_id        uuid,
  type           text not null,          -- offre | demande
  categorie      text,                   -- marchandise, frigo, personnel, kira...
  titre          text not null,
  ville_depart   text,
  ville_arrivee  text,
  type_vehicule  text,
  date_souhaitee text,
  prix           numeric,
  unite          text,
  description    text,
  telephone      text,
  nom            text,
  photo_url      text,
  premium        boolean default false,
  actif          boolean default true,
  nb_vues        integer default 0,
  note           numeric
);
create index if not exists annonces_naql_type_idx  on public.annonces_naql (type, actif);
create index if not exists annonces_naql_cat_idx   on public.annonces_naql (categorie);
create index if not exists annonces_naql_user_idx  on public.annonces_naql (user_id);

-- 3) ROW LEVEL SECURITY ------------------------------------------
-- L'app utilise la clé "anon" + une auth maison (téléphone+nom),
-- donc on ouvre les accès en lecture/écriture à anon (comme سوق المقاول).
-- Pour durcir plus tard : passer à Supabase Auth + policies par auth.uid().
alter table public.users_naql    enable row level security;
alter table public.annonces_naql enable row level security;

drop policy if exists "users_all" on public.users_naql;
create policy "users_all" on public.users_naql
  for all to anon, authenticated using (true) with check (true);

drop policy if exists "annonces_all" on public.annonces_naql;
create policy "annonces_all" on public.annonces_naql
  for all to anon, authenticated using (true) with check (true);

-- 4) STORAGE (photos) --------------------------------------------
-- Crée le bucket public "photos_naql"
insert into storage.buckets (id, name, public)
values ('photos_naql', 'photos_naql', true)
on conflict (id) do nothing;

drop policy if exists "photos_read"   on storage.objects;
drop policy if exists "photos_write"  on storage.objects;
create policy "photos_read"  on storage.objects
  for select to anon, authenticated using (bucket_id = 'photos_naql');
create policy "photos_write" on storage.objects
  for insert to anon, authenticated with check (bucket_id = 'photos_naql');

-- 5) (Optionnel) quelques annonces de démonstration --------------
insert into public.annonces_naql (type,categorie,titre,ville_depart,ville_arrivee,type_vehicule,date_souhaitee,prix,unite,description,telephone,nom,premium,actif,note)
values
('offre','frigo','كاميو مبرّد 10 طن متوفر فجهة سوس','أكادير','كاع المغرب','كاميو مبرّد','متوفر دابا',null,'حسب المسافة','كاميو مبرّد، مناسب للخضرة والحوت.','212661112233','النقل السريع',true,true,4.9),
('demande','marchandise','بغيت ننقل 5 طن ديال الخضرة من أكادير لكازا','أكادير','الدار البيضاء','كاميو','05/06/2026',1800,'درهم','5 طن خضرة، التحميل والتفريغ على حسابي.','212665556677','يوسف',false,true,4.6)
on conflict do nothing;
