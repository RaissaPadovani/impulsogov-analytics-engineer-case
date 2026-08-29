-- esquema incial para entender os dados
-- Este arquivo reúne consultas de investigação; ele não é um model dbt
-- A forma mais prática de executá-las é usar o script scripts/run_profiling.py

-- 1) Volumes e chaves candidatas
select
    'cidadao_pec' as tabela,
    count(*) as linhas,
    count(distinct co_fat_cidadao_pec) as chaves_distintas
from {{ ref('stg_cidadao_pec') }}
union all
select
    'atendimento_individual',
    count(*),
    count(distinct co_seq_fat_atd_ind)
from {{ ref('stg_atendimento_individual') }}
union all
select
    'procedimentos',
    count(*),
    count(distinct co_seq_fat_proced)
from {{ ref('stg_procedimentos') }};

-- 2) Classificações de atendimento
select atend_ind_classificacao, count(*) as linhas
from {{ ref('stg_atendimento_individual') }}
group by 1
order by 2 desc;

-- 3) CBOs presentes nos atendimentos
select nu_cbo, no_cbo, count(*) as linhas
from {{ ref('stg_atendimento_individual') }}
group by 1, 2
order by 3 desc;

-- 4) Procedimentos presentes
select ds_proced, count(*) as linhas
from {{ ref('stg_procedimentos') }}
group by 1
order by 2 desc;

-- 5) Registros posteriores à data de referência
select
    'cidadao_nascimento_futuro' as checagem,
    count(*) as linhas
from {{ ref('stg_cidadao_pec') }}
where dt_registro_nascimento > date '{{ var("reference_date") }}'
union all
select
    'atendimento_futuro',
    count(*)
from {{ ref('stg_atendimento_individual') }}
where dt_registro > date '{{ var("reference_date") }}'
union all
select
    'procedimento_futuro',
    count(*)
from {{ ref('stg_procedimentos') }}
where dt_registro > date '{{ var("reference_date") }}';

-- 6) Cobertura dos campos de medida de pressão
select
    count(*) filter (where ds_proced = 'AFERIÇÃO DE PRESSÃO ARTERIAL') as afericoes,
    count(*) filter (
        where ds_proced = 'AFERIÇÃO DE PRESSÃO ARTERIAL'
          and qt_afericao_pressao_arterial is not null
    ) as pressao_coluna_documentada_preenchida,
    count(*) filter (
        where ds_proced = 'AFERIÇÃO DE PRESSÃO ARTERIAL'
          and propriedades is not null
    ) as propriedades_preenchidas
from {{ ref('stg_procedimentos') }};

-- 7) INEs com mais de uma grafia de nome de equipe
select
    nu_ine,
    count(distinct no_equipe) as nomes_distintos,
    string_agg(distinct no_equipe, ' | ' order by no_equipe) as nomes
from {{ ref('stg_cidadao_pec') }}
where nu_ine is not null
  and no_equipe is not null
group by 1
having count(distinct no_equipe) > 1
order by nomes_distintos desc, nu_ine;
