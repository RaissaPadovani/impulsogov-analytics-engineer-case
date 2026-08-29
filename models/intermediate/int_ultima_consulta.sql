-- Intermediate: última consulta válida e status da boa prática de consulta.
-- Regra do case:
--   * atendimento individual por médico ou enfermeiro;
--   * qualquer local de atendimento;
--   * eventos posteriores ao snapshot não contam;
--   * Em dia = última consulta nos 6 meses anteriores à data de referência;
--   * Atrasada = existe consulta, mas está fora da janela;
--   * Nunca realizada = não existe consulta válida no histórico.

with parameters as (

    select cast('{{ var("reference_date") }}' as date) as reference_date

),

valid_consultations as (

    select
        a.co_fat_cidadao_pec,
        a.dt_registro
    from {{ ref('stg_atendimento_individual') }} as a
    cross join parameters as p
    where a.dt_registro <= p.reference_date
      -- Famílias CBO válidas para consulta: médicos e enfermeiros.
      and substr(a.nu_cbo, 1, 4) in (
          '2231',
          '2235',
          '2251',
          '2252',
          '2253'
      )

),

last_consultation as (

    select
        co_fat_cidadao_pec,
        max(dt_registro) as dt_ultima_consulta
    from valid_consultations
    group by co_fat_cidadao_pec

)

select
    p.co_fat_cidadao_pec,
    c.dt_ultima_consulta,
    case
        when c.dt_ultima_consulta is null then 'Nunca realizada'
        when c.dt_ultima_consulta >= p.data_referencia - interval '6 months' then 'Em dia'
        else 'Atrasada'
    end as status_consulta
from {{ ref('int_populacao_hipertensao') }} as p
left join last_consultation as c
    on p.co_fat_cidadao_pec = c.co_fat_cidadao_pec
