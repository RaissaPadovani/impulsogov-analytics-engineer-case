-- Intermediate: último registro válido e simultâneo de peso e altura
-- e status da boa prática.
--
-- Regra do case:
--   * procedimento = MEDIÇÃO PESO E ALTURA;
--   * peso e altura precisam existir no mesmo registro/dia;
--   * profissionais válidos: médicos, enfermeiros, técnicos de enfermagem
--     e agentes comunitários de saúde;
--   * eventos posteriores ao snapshot não contam;
--   * Em dia = registro mais recente nos 12 meses anteriores à data de referência;
--   * Atrasada = existe registro, mas está fora da janela;
--   * Nunca realizada = não existe registro válido no histórico.

with parameters as (

    select cast('{{ var("reference_date") }}' as date) as reference_date

),

valid_weight_height as (

    select
        p.co_seq_fat_proced,
        p.co_fat_cidadao_pec,
        p.dt_registro,
        p.data_transmissao,
        p.peso,
        p.altura_cm
    from {{ ref('stg_procedimentos') }} as p
    cross join parameters as par
    where p.dt_registro <= par.reference_date
      and p.ds_proced = 'MEDIÇÃO PESO E ALTURA'
      and p.peso is not null
      and p.altura_cm is not null
      and substr(p.nu_cbo, 1, 4) in (
          '2231',
          '2235',
          '2251',
          '2252',
          '2253',
          '3222',
          '5151'
      )

),

ranked_weight_height as (

    select
        *,
        row_number() over (
            partition by co_fat_cidadao_pec
            order by
                dt_registro desc,
                data_transmissao desc,
                co_seq_fat_proced desc
        ) as rn
    from valid_weight_height

),

last_weight_height as (

    select
        co_fat_cidadao_pec,
        dt_registro as dt_ultimo_peso_altura,
        peso as ultimo_peso,
        altura_cm as ultima_altura_cm
    from ranked_weight_height
    where rn = 1

)

select
    pop.co_fat_cidadao_pec,
    wh.dt_ultimo_peso_altura,
    wh.ultimo_peso,
    wh.ultima_altura_cm,
    case
        when wh.dt_ultimo_peso_altura is null then 'Nunca realizada'
        when wh.dt_ultimo_peso_altura >= pop.data_referencia - interval '12 months' then 'Em dia'
        else 'Atrasada'
    end as status_peso_altura
from {{ ref('int_populacao_hipertensao') }} as pop
left join last_weight_height as wh
    on pop.co_fat_cidadao_pec = wh.co_fat_cidadao_pec
