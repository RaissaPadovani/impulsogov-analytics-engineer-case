-- Gold: tabela final que alimenta a Lista Nominal de Hipertensão
-- Granularidade: uma linha por cidadão elegível na data de referência
--
-- A Gold expõe apenas os atributos necessários para a operação da lista nominal
-- e os resultados das três boas práticas calculadas nas camadas intermediárias
--
-- Microárea NÃO está disponível nas fontes fornecidas e, por isso, não é
-- inventada nesta tabela. Essa limitação deve ser registrada para Produto

with final as (

    select
        pop.co_fat_cidadao_pec,
        pop.no_cidadao,

        -- O nome é necessário para a operação da tela, mas a origem possui
        -- cidadãos elegíveis sem nome. Mantemos essas pessoas na lista para não
        -- esconder uma necessidade de cuidado por falha cadastral e sinalizamos
        -- explicitamente o problema de qualidade.
        case
            when pop.no_cidadao is null then true
            else false
        end as st_nome_ausente,

        -- Datas de nascimento posteriores ao snapshot são tratadas como inválidas
        -- para exibição/cálculo de idade, sem excluir a pessoa da lista.
        case
            when pop.dt_registro_nascimento <= pop.data_referencia
                then pop.dt_registro_nascimento
        end as dt_nascimento,

        case
            when pop.dt_registro_nascimento is null
              or pop.dt_registro_nascimento > pop.data_referencia
                then null
            else cast(
                date_part('year', pop.data_referencia)
                - date_part('year', pop.dt_registro_nascimento)
                - case
                    when (
                        date_part('month', pop.data_referencia) * 100
                        + date_part('day', pop.data_referencia)
                    ) < (
                        date_part('month', pop.dt_registro_nascimento) * 100
                        + date_part('day', pop.dt_registro_nascimento)
                    )
                    then 1
                    else 0
                  end
                as integer
            )
        end as idade,

        case
            when pop.dt_registro_nascimento is not null
             and pop.dt_registro_nascimento > pop.data_referencia
                then true
            else false
        end as st_data_nascimento_invalida,

        pop.nu_cns,
        pop.nu_cpf_cidadao,
        pop.nu_telefone_celular,
        pop.nu_ine,
        pop.no_equipe,

        consulta.dt_ultima_consulta,
        consulta.status_consulta,

        pressao.dt_ultima_pressao,
        pressao.valor_ultima_pressao,
        pressao.status_pressao,

        peso_altura.dt_ultimo_peso_altura,
        peso_altura.ultimo_peso,
        peso_altura.ultima_altura_cm,
        peso_altura.status_peso_altura,

        case
            when consulta.status_consulta = 'Em dia'
             and pressao.status_pressao = 'Em dia'
             and peso_altura.status_peso_altura = 'Em dia'
                then false
            else true
        end as st_possui_pendencia,

        pop.data_referencia

    from {{ ref('int_populacao_hipertensao') }} as pop

    inner join {{ ref('int_ultima_consulta') }} as consulta
        on pop.co_fat_cidadao_pec = consulta.co_fat_cidadao_pec

    inner join {{ ref('int_ultima_pressao') }} as pressao
        on pop.co_fat_cidadao_pec = pressao.co_fat_cidadao_pec

    inner join {{ ref('int_ultimo_peso_altura') }} as peso_altura
        on pop.co_fat_cidadao_pec = peso_altura.co_fat_cidadao_pec

)

select *
from final
