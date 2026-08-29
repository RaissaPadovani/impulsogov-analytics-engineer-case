-- Camada Bronze: espelho do CSV bruto.

select *
from read_csv_auto(
    '{{ var("data_path") }}/atendimento_individual.csv',
    header = true,
    all_varchar = true
)
