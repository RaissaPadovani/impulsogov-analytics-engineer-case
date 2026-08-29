-- Intermediate: população elegível para a Lista Nominal de Hipertensão
-- Regra adotada para condição resolvida: considerar o evento de condição mais recente
-- até a data de referência. Assim, um novo registro de HIPERTENSÃO após uma resolução
-- reativa a pessoa na lista

with parameters as (

    select cast('{{ var("reference_date") }}' as date) as reference_date

),

condition_events as (

    select
        a.co_seq_fat_atd_ind,
        a.co_fat_cidadao_pec,
        a.atend_ind_classificacao,
        a.dt_registro,
        a.nu_cbo
    from {{ ref('stg_atendimento_individual') }} as a
    cross join parameters as p
    where a.dt_registro <= p.reference_date
      and a.atend_ind_classificacao in (
          'HIPERTENSÃO',
          'HIPERTENSÃO - CONDIÇÃO RESOLVIDA'
      )
      -- Famílias CBO de médicos e enfermeiros definidas na regra do case.
      and substr(a.nu_cbo, 1, 4) in (
          '2231',
          '2235',
          '2251',
          '2252',
          '2253'
      )

),

latest_condition as (

    select
        *,
        row_number() over (
            partition by co_fat_cidadao_pec
            order by
                dt_registro desc,
                -- Desempate conservador: se houver diagnóstico e resolução no mesmo dia,
                -- a resolução prevalece. Não há caso desse tipo nos dados fornecidos,
                -- mas o critério deixa o resultado determinístico.
                case
                    when atend_ind_classificacao = 'HIPERTENSÃO - CONDIÇÃO RESOLVIDA' then 1
                    else 0
                end desc,
                co_seq_fat_atd_ind desc
        ) as rn
    from condition_events

),

current_hypertension as (

    select
        co_fat_cidadao_pec,
        dt_registro as dt_ultima_condicao_hipertensao,
        atend_ind_classificacao as classificacao_atual_hipertensao
    from latest_condition
    where rn = 1
      and atend_ind_classificacao = 'HIPERTENSÃO'

)

select
    c.co_fat_cidadao_pec,
    c.no_cidadao,
    c.dt_registro_nascimento,
    c.ds_sexo,
    c.nu_cns,
    c.nu_cpf_cidadao,
    c.nu_telefone_celular,
    c.nu_ine,
    c.no_equipe,
    h.dt_ultima_condicao_hipertensao,
    h.classificacao_atual_hipertensao,
    p.reference_date as data_referencia
from current_hypertension as h
inner join {{ ref('stg_cidadao_pec') }} as c
    on h.co_fat_cidadao_pec = c.co_fat_cidadao_pec
cross join parameters as p
where coalesce(c.st_faleceu, 0) <> 1
