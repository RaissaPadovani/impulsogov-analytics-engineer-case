-- Intermediate: última aferição válida de pressão arterial e status da boa prática.
-- Regra do case:
--   * procedimento = AFERIÇÃO DE PRESSÃO ARTERIAL;
--   * profissionais válidos: médicos, enfermeiros e técnicos/auxiliares de enfermagem;
--   * qualquer equipe/local habilitado da APS conta;
--   * eventos posteriores ao snapshot não contam;
--   * Em dia = última aferição nos 6 meses anteriores à data de referência;
--   * Atrasada = existe aferição, mas está fora da janela;
--   * Nunca realizada = não existe aferição válida no histórico.
--
-- Observação de qualidade:
-- o campo documentado qt_afericao_pressao_arterial veio vazio no dataset.
-- O valor exibido é extraído de propriedades.pressao_arterial na Silver.

with parameters as (

    select cast('{{ var("reference_date") }}' as date) as reference_date

),

valid_blood_pressure as (

    select
        p.co_seq_fat_proced,
        p.co_fat_cidadao_pec,
        p.dt_registro,
        p.data_transmissao,
        p.pressao_arterial
    from {{ ref('stg_procedimentos') }} as p
    cross join parameters as par
    where p.dt_registro <= par.reference_date
      and p.ds_proced = 'AFERIÇÃO DE PRESSÃO ARTERIAL'
      and substr(p.nu_cbo, 1, 4) in (
          '2231',
          '2235',
          '2251',
          '2252',
          '2253',
          '3222'
      )

),

ranked_blood_pressure as (

    select
        *,
        row_number() over (
            partition by co_fat_cidadao_pec
            order by
                dt_registro desc,
                data_transmissao desc,
                co_seq_fat_proced desc
        ) as rn
    from valid_blood_pressure

),

last_blood_pressure as (

    select
        co_fat_cidadao_pec,
        dt_registro as dt_ultima_pressao,
        pressao_arterial as valor_ultima_pressao
    from ranked_blood_pressure
    where rn = 1

)

select
    pop.co_fat_cidadao_pec,
    bp.dt_ultima_pressao,
    bp.valor_ultima_pressao,
    case
        when bp.dt_ultima_pressao is null then 'Nunca realizada'
        when bp.dt_ultima_pressao >= pop.data_referencia - interval '6 months' then 'Em dia'
        else 'Atrasada'
    end as status_pressao
from {{ ref('int_populacao_hipertensao') }} as pop
left join last_blood_pressure as bp
    on pop.co_fat_cidadao_pec = bp.co_fat_cidadao_pec
