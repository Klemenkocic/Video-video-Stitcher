-- Function to deduct credits from user account
create or replace function public.deduct_credits(amount int, description text)
returns boolean as $$
declare
  current_credits int;
  user_id_val uuid;
begin
  user_id_val := auth.uid();

  select credits into current_credits
  from public.profiles
  where id = user_id_val;

  if current_credits < amount then
    return false;
  end if;

  update public.profiles
  set credits = credits - amount,
      updated_at = timezone('utc'::text, now())
  where id = user_id_val;

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

  update public.profiles
  set credits = credits + amount,
      updated_at = timezone('utc'::text, now())
  where id = user_id_val;

  insert into public.credit_transactions (user_id, amount, transaction_type, description)
  values (user_id_val, amount, 'top_up', description);
end;
$$ language plpgsql security definer;

-- Admin function to add credits to any user (for webhook use)
create or replace function public.top_up_credits_admin(user_id_param uuid, amount_param int, description_param text)
returns void as $$
begin
  update public.profiles
  set credits = credits + amount_param,
      updated_at = timezone('utc'::text, now())
  where id = user_id_param;

  insert into public.credit_transactions (user_id, amount, transaction_type, description)
  values (user_id_param, amount_param, 'top_up', description_param);
end;
$$ language plpgsql security definer;
