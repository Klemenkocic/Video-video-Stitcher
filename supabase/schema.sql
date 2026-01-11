-- Enable UUID extension
create extension if not exists "uuid-ossp";

-- PROFILES TABLE
create table profiles (
  id uuid references auth.users not null primary key,
  display_name text,
  avatar_url text,
  credits integer default 0,
  subscription_tier text default 'free',
  stripe_customer_id text,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  updated_at timestamp with time zone default timezone('utc'::text, now()) not null
);

alter table profiles enable row level security;

create policy "Public profiles are viewable by everyone."
  on profiles for select
  using ( true );

create policy "Users can insert their own profile."
  on profiles for insert
  with check ( auth.uid() = id );

create policy "Users can update their own profile."
  on profiles for update
  using ( auth.uid() = id );

-- PROJECTS TABLE
create table projects (
  id uuid default uuid_generate_v4() primary key,
  user_id uuid references profiles(id) not null,
  title text default 'Untitled Project',
  status text default 'draft', -- draft, ready, generating, completed, failed
  nodes jsonb default '[]'::jsonb,
  video_url text,
  video_thumbnail_url text,
  credits_cost integer default 0,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  updated_at timestamp with time zone default timezone('utc'::text, now()) not null
);

alter table projects enable row level security;

create policy "Users can view their own projects."
  on projects for select
  using ( auth.uid() = user_id );

create policy "Users can create their own projects."
  on projects for insert
  with check ( auth.uid() = user_id );

create policy "Users can update their own projects."
  on projects for update
  using ( auth.uid() = user_id );

create policy "Users can delete their own projects."
  on projects for delete
  using ( auth.uid() = user_id );

-- CREDIT TRANSACTIONS TABLE
create table credit_transactions (
  id uuid default uuid_generate_v4() primary key,
  user_id uuid references profiles(id) not null,
  amount integer not null,
  transaction_type text not null,
  description text,
  reference_id text,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

alter table credit_transactions enable row level security;

create policy "Users can view their own transactions."
  on credit_transactions for select
  using ( auth.uid() = user_id );

-- No insert/update policy for client - must be server-side only functions

-- TRIGGER: Auto-create profile on user signup
create or replace function public.handle_new_user()
returns trigger as $$
begin
  insert into public.profiles (id, display_name, credits)
  values (new.id, new.email, 0);
  return new;
end;
$$ language plpgsql security definer;

-- Trigger the function every time a user is created
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();

-- CREDIT MANAGEMENT FUNCTIONS

-- Function to deduct credits from user account
create or replace function public.deduct_credits(amount int, description text)
returns boolean as $$
declare
  current_credits int;
  user_id_val uuid;
begin
  user_id_val := auth.uid();

  -- Get current credits
  select credits into current_credits
  from public.profiles
  where id = user_id_val;

  -- Check if user has enough credits
  if current_credits < amount then
    return false;
  end if;

  -- Deduct credits
  update public.profiles
  set credits = credits - amount,
      updated_at = timezone('utc'::text, now())
  where id = user_id_val;

  -- Record transaction
  insert into public.credit_transactions (user_id, amount, transaction_type, description)
  values (user_id_val, -amount, 'deduction', description);

  return true;
end;
$$ language plpgsql security definer;

-- Function to add credits to user account
create or replace function public.top_up_credits(amount int, description text)
returns void as $$
declare
  user_id_val uuid;
begin
  user_id_val := auth.uid();

  -- Add credits
  update public.profiles
  set credits = credits + amount,
      updated_at = timezone('utc'::text, now())
  where id = user_id_val;

  -- Record transaction
  insert into public.credit_transactions (user_id, amount, transaction_type, description)
  values (user_id_val, amount, 'top_up', description);
end;
$$ language plpgsql security definer;
