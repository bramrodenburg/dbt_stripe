{% set fields = ['rolling_total_daily_sales_amount', 'rolling_total_daily_refunds_amount', 'rolling_total_daily_adjustments_amount', 'rolling_total_daily_other_transactions_amount', 'rolling_total_daily_gross_transaction_amount', 'rolling_total_daily_net_transactions_amount', 'rolling_total_daily_payout_fee_amount', 'rolling_total_daily_gross_payout_amount', 'rolling_daily_net_activity_amount', 'rolling_daily_end_balance_amount', 'rolling_total_daily_sales_count', 'rolling_total_daily_payouts_count', 'rolling_total_daily_adjustments_count', 'rolling_total_daily_failed_charge_count', 'rolling_total_daily_failed_charge_amount'] %}

with date_spine as (

    select * 
    from {{ ref('int_stripe__date_spine') }}

), account_daily_balances_by_type as (

    select * 
    from {{ ref('int_stripe__account_daily')}}

    -- select 
    --     account_id,
    --     date_day,
    --     sum(amount) as daily_amount,
    --     sum(case when lower(reporting_category) = 'charge' 
    --         then amount
    --         else 0 
    --         end) as daily_charge_amount,
    --     sum(case when lower(reporting_category) = 'refund' 
    --         then amount
    --         else 0 
    --         end) as daily_refund_amount,
    --     sum(case when lower(reporting_category) = 'payout_reversal' 
    --         then amount
    --         else 0 
    --         end) as daily_payout_reversal_amount,
    --     sum(case when lower(reporting_category) = 'transfer' 
    --         then amount
    --         else 0 
    --         end) as daily_transfer_count,
    --     sum(case when lower(reporting_category) = 'transfer_reversal' 
    --         then amount
    --         else 0 
    --         end) as daily_transfer_reversal_amount
    --     sum(case when lower(reporting_category) not in ('charge','refund','payout_reversal','transfer','transfer_reversal')
    --         then amount
    --         else 0
    --         end) as daily_other_amount
    -- from transactions_grouped
    -- group by 1, 2
-- ),

), account_rolling_totals as (

    select
        *,
        sum(total_daily_sales_amount) over (partition by account_id order by account_id, date_day rows unbounded preceding) as rolling_total_daily_sales_amount,
        sum(total_daily_refunds_amount) over (partition by account_id order by account_id, date_day rows unbounded preceding) as rolling_total_daily_refunds_amount,
        sum(total_daily_adjustments_amount) over (partition by account_id order by account_id, date_day rows unbounded preceding) as rolling_total_daily_adjustments_amount,
        sum(total_daily_other_transactions_amount) over (partition by account_id order by account_id, date_day rows unbounded preceding) as rolling_total_daily_other_transactions_amount,
        sum(total_daily_gross_transaction_amount) over (partition by account_id order by account_id, date_day rows unbounded preceding) as rolling_total_daily_gross_transaction_amount,
        sum(total_daily_net_transactions_amount) over (partition by account_id order by account_id, date_day rows unbounded preceding) as rolling_total_daily_net_transactions_amount,
        sum(total_daily_payout_fee_amount) over (partition by account_id order by account_id, date_day rows unbounded preceding) as rolling_total_daily_payout_fee_amount,
        sum(total_daily_gross_payout_amount) over (partition by account_id order by account_id, date_day rows unbounded preceding) as rolling_total_daily_gross_payout_amount,
        sum(daily_net_activity_amount) over (partition by account_id order by account_id, date_day rows unbounded preceding) as rolling_daily_net_activity_amount,
        sum(daily_end_balance_amount) over (partition by account_id order by account_id, date_day rows unbounded preceding) as rolling_daily_end_balance_amount,
        sum(total_daily_sales_count) over (partition by account_id order by account_id, date_day rows unbounded preceding) as rolling_total_daily_sales_count,
        sum(total_daily_payouts_count) over (partition by account_id order by account_id, date_day rows unbounded preceding) as rolling_total_daily_payouts_count,
        sum(total_daily_adjustments_count) over (partition by account_id order by account_id, date_day rows unbounded preceding) as rolling_total_daily_adjustments_count,
        sum(total_daily_failed_charge_count) over (partition by account_id order by account_id, date_day rows unbounded preceding) as rolling_total_daily_failed_charge_count,
        sum(total_daily_failed_charge_amount) over (partition by account_id order by account_id, date_day rows unbounded preceding) as rolling_total_daily_failed_charge_amount


        -- sum(total_daily_sales_amount) over (partition by account_id order by account_id, date_day rows unbounded preceding) as rolling_daily_amount,
        -- sum(daily_charge_amount) over (partition by account_id order by account_id, date_day rows unbounded preceding) as rolling_daily_charge_amount,
        -- sum(total_daily_refunds_amount) over (partition by account_id order by account_id, date_day rows unbounded preceding) as rolling_daily_refund_amount,
        -- sum(daily_payout_reversal_amount) over (partition by account_id order by account_id, date_day rows unbounded preceding) as rolling_daily_payout_reversal_amount,
        -- sum(daily_transfer_count) over (partition by account_id order by account_id, date_day rows unbounded preceding) as rolling_daily_transfer_count,
        -- sum(daily_transfer_reversal_amount) over (partition by account_id order by account_id, date_day rows unbounded preceding) as rolling_daily_transfer_reversal_amount,
        -- sum(daily_other_amount) over (partition by account_id order by account_id, date_day rows unbounded preceding) as rolling_daily_other_amount
    
    from account_daily_balances_by_type

), final as (

    select
        coalesce(account_rolling_totals.account_id, balance_transaction_periods.account_id) as account_id,
        coalesce(account_rolling_totals.date_day, balance_transaction_periods.date_day) as date_day,
        account_rolling_totals.total_daily_sales_amount,
        account_rolling_totals.total_daily_refunds_amount,
        account_rolling_totals.total_daily_adjustments_amount,
        account_rolling_totals.total_daily_other_transactions_amount,
        account_rolling_totals.total_daily_gross_transaction_amount,
        account_rolling_totals.total_daily_net_transactions_amount,
        account_rolling_totals.total_daily_payout_fee_amount,
        account_rolling_totals.total_daily_gross_payout_amount,
        account_rolling_totals.daily_net_activity_amount,
        account_rolling_totals.daily_end_balance_amount,
        account_rolling_totals.total_daily_sales_count,
        account_rolling_totals.total_daily_payouts_count,
        account_rolling_totals.total_daily_adjustments_count,
        account_rolling_totals.total_daily_failed_charge_count,
        account_rolling_totals.total_daily_failed_charge_amount,

        -- account_rolling_totals.daily_amount,
        -- account_rolling_totals.daily_charge_amount,
        -- account_rolling_totals.daily_refund_amount,
        -- account_rolling_totals.daily_payout_reversal_amount,
        -- account_rolling_totals.daily_transfer_count,
        -- account_rolling_totals.daily_transfer_reversal_amount,
        -- account_rolling_totals.daily_other_amount,

        {% for f in fields %}
        case when account_rolling_totals.{{ f }} is null and date_index = 1
            then 0
            else account_rolling_totals.{{ f }}
            end as {{ f }},
        {% endfor %}

        balance_transaction_periods.date_index
    from balance_transaction_periods

    left join account_rolling_totals
        on account_rolling_totals.account_id = balance_transaction_periods.account_id 
        and account_rolling_totals.date_day = balance_transaction_periods.date_day
)

select * 
from final
