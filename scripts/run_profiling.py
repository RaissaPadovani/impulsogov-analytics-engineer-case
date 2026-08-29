from pathlib import Path
import duckdb
import pandas as pd

ROOT = Path(__file__).resolve().parents[1]
DB_PATH = ROOT / "impulsogov.duckdb"
OUT_PATH = ROOT / "resultados" / "profiling.md"
REFERENCE_DATE = "2026-08-01"

QUERIES = [
    (
        "Volumes e chaves candidatas",
        """
        select 'cidadao_pec' as tabela,
               count(*) as linhas,
               count(distinct co_fat_cidadao_pec) as chaves_distintas
        from main_silver.stg_cidadao_pec
        union all
        select 'atendimento_individual', count(*), count(distinct co_seq_fat_atd_ind)
        from main_silver.stg_atendimento_individual
        union all
        select 'procedimentos', count(*), count(distinct co_seq_fat_proced)
        from main_silver.stg_procedimentos
        """,
    ),
    (
        "Classificações de atendimento",
        """
        select atend_ind_classificacao, count(*) as linhas
        from main_silver.stg_atendimento_individual
        group by 1
        order by 2 desc
        """,
    ),
    (
        "CBOs em atendimento_individual",
        """
        select nu_cbo, no_cbo, count(*) as linhas
        from main_silver.stg_atendimento_individual
        group by 1, 2
        order by 3 desc
        """,
    ),
    (
        "Procedimentos presentes",
        """
        select ds_proced, count(*) as linhas
        from main_silver.stg_procedimentos
        group by 1
        order by 2 desc
        """,
    ),
    (
        "Registros posteriores à data de referência",
        f"""
        select 'cidadao_nascimento_futuro' as checagem, count(*) as linhas
        from main_silver.stg_cidadao_pec
        where dt_registro_nascimento > date '{REFERENCE_DATE}'
        union all
        select 'atendimento_futuro', count(*)
        from main_silver.stg_atendimento_individual
        where dt_registro > date '{REFERENCE_DATE}'
        union all
        select 'procedimento_futuro', count(*)
        from main_silver.stg_procedimentos
        where dt_registro > date '{REFERENCE_DATE}'
        """,
    ),
    (
        "Duplicidade por identificador entre transmissões",
        """
        select 'atendimento_individual' as tabela,
               count(*) as linhas,
               count(distinct co_seq_fat_atd_ind) as ids_distintos,
               count(*) - count(distinct co_seq_fat_atd_ind) as linhas_repetidas
        from main_silver.stg_atendimento_individual
        union all
        select 'procedimentos', count(*), count(distinct co_seq_fat_proced),
               count(*) - count(distinct co_seq_fat_proced)
        from main_silver.stg_procedimentos
        """,
    ),
    (
        "Cobertura dos campos de pressão",
        """
        select
            count(*) filter (where ds_proced = 'AFERIÇÃO DE PRESSÃO ARTERIAL') as afericoes,
            count(*) filter (
                where ds_proced = 'AFERIÇÃO DE PRESSÃO ARTERIAL'
                  and qt_afericao_pressao_arterial is not null
            ) as campo_documentado_preenchido,
            count(*) filter (
                where ds_proced = 'AFERIÇÃO DE PRESSÃO ARTERIAL'
                  and propriedades is not null
            ) as propriedades_preenchidas
        from main_silver.stg_procedimentos
        """,
    ),
    (
        "INEs com múltiplas grafias de nome de equipe",
        """
        select
            nu_ine,
            count(distinct no_equipe) as nomes_distintos,
            string_agg(distinct no_equipe, ' | ' order by no_equipe) as nomes
        from main_silver.stg_cidadao_pec
        where nu_ine is not null and no_equipe is not null
        group by 1
        having count(distinct no_equipe) > 1
        order by nomes_distintos desc, nu_ine
        """,
    ),
]


def markdown_table(df: pd.DataFrame) -> str:
    if df.empty:
        return "_Nenhuma linha retornada._\n"
    cols = [str(c) for c in df.columns]
    rows = [["" if pd.isna(v) else str(v) for v in row] for row in df.itertuples(index=False, name=None)]
    widths = [max(len(cols[i]), *(len(row[i]) for row in rows)) for i in range(len(cols))]
    header = "| " + " | ".join(cols[i].ljust(widths[i]) for i in range(len(cols))) + " |"
    sep = "| " + " | ".join("-" * widths[i] for i in range(len(cols))) + " |"
    body = "\n".join("| " + " | ".join(row[i].ljust(widths[i]) for i in range(len(cols))) + " |" for row in rows)
    return f"{header}\n{sep}\n{body}\n"


def main() -> None:
    if not DB_PATH.exists():
        raise SystemExit(
            "Banco não encontrado. Rode primeiro: dbt build --profiles-dir ."
        )

    con = duckdb.connect(str(DB_PATH), read_only=True)
    sections = [
        "# Profiling inicial",
        "",
        f"Data de referência do case: **{REFERENCE_DATE}**.",
        "",
        "> Este arquivo é gerado por `scripts/run_profiling.py`. Não edite os números manualmente.",
        "",
    ]

    for title, sql in QUERIES:
        df = con.execute(sql).df()
        sections.extend([f"## {title}", "", markdown_table(df), ""])

    OUT_PATH.parent.mkdir(parents=True, exist_ok=True)
    OUT_PATH.write_text("\n".join(sections), encoding="utf-8")
    print(f"Profiling salvo em: {OUT_PATH}")


if __name__ == "__main__":
    main()
