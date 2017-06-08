with overall_table as(
  select i.sku,u.state,sum(i.price) as amount  
  from items i
  inner join carts c on (c.id = i.id and c.purchase_date is not null)
  inner join product p on (i.sku = p.sku )
  inner join users u on (c.name = u.name)
  group by i.sku,u.state
),
top_state as(
  select state, sum(amount) as dollar from (
  select state, amount from overall_table
  UNION ALL
  select state as state, 0.0 as amount from state
  ) as state_union
  group by state order by dollar desc
),
top_n_state as(
  select row_number() over(order by dollar desc) as state_order, state, dollar from top_state
),
top_prod as(
  select sku, sum(amount) as dollar from (
  select sku, amount from overall_table
  UNION ALL
  select sku as sku, 0.0 as amount from product
  ) as product_union
  group by sku order by dollar desc
),
top_n_prod as (
  select row_number() over(order by dollar desc) as product_order, sku, dollar from top_prod
)
select ts.state, s.state, tp.sku, pr.product_name, COALESCE(ot.amount, 0.0) as cell_sum, ts.dollar as state_sum, tp.dollar as product_sum
  from top_n_prod tp CROSS JOIN top_n_state ts 
  LEFT OUTER JOIN overall_table ot 
  ON ( tp.sku = ot.sku and ts.state = ot.state)
  inner join state s ON ts.state = s.state
  inner join product pr ON tp.sku = pr.sku
  order by ts.state_order, tp.product_order