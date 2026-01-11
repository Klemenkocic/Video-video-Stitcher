-- Add this to your SQL Editor in Supabase

-- Function to safely deduct credits
create or replace function deduct_credits(amount int, description text)
returns boolean
language plpgsql
security definer
as $$
declare
  current_credits int;
begin
  -- Get current credits
  select credits into current_credits
  from profiles
  where id = auth.uid();

  -- Check sufficiency
  if current_credits >= amount then
    -- Deduct
    update profiles
    set credits = credits - amount,
        updated_at = now()
    where id = auth.uid();

    -- Log transaction
    insert into credit_transactions (user_id, amount, transaction_type, description)
    values (auth.uid(), -amount, 'usage', description);

    return true;
  else
    return false;
  end if;
end;
$$;

-- Function to top up credits (simulated for dev, usually handled by webhook)
create or replace function top_up_credits(amount int, description text)
returns void
language plpgsql
security definer
as $$
begin
  update profiles
  set credits = credits + amount,
      updated_at = now()
  where id = auth.uid();

  insert into credit_transactions (user_id, amount, transaction_type, description)
  values (auth.uid(), amount, 'purchase', description);
end;
$$;
