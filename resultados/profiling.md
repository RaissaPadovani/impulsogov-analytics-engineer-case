# Profiling inicial

Data de referência do case: **2026-08-01**.

> Este arquivo é gerado por `scripts/run_profiling.py`. Não edite os números manualmente.

## Volumes e chaves candidatas

| tabela                 | linhas | chaves_distintas |
| ---------------------- | ------ | ---------------- |
| cidadao_pec            | 1200   | 1200             |
| atendimento_individual | 5545   | 3990             |
| procedimentos          | 4252   | 3179             |


## Classificações de atendimento

| atend_ind_classificacao          | linhas |
| -------------------------------- | ------ |
| GERAL                            | 4138   |
| HIPERTENSÃO                      | 1115   |
| DIABETES                         | 195    |
| HIPERTENSÃO - CONDIÇÃO RESOLVIDA | 97     |


## CBOs em atendimento_individual

| nu_cbo | no_cbo                                       | linhas |
| ------ | -------------------------------------------- | ------ |
| 223565 | ENFERMEIRO DA ESTRATÉGIA DE SAÚDE DA FAMÍLIA | 1453   |
| 225142 | MÉDICO DA ESTRATÉGIA DE SAÚDE DA FAMÍLIA     | 1368   |
| 223505 | ENFERMEIRO                                   | 1352   |
| 225125 | MÉDICO CLÍNICO                               | 1318   |
| 322205 | TÉCNICO DE ENFERMAGEM                        | 54     |


## Procedimentos presentes

| ds_proced                    | linhas |
| ---------------------------- | ------ |
| AFERIÇÃO DE PRESSÃO ARTERIAL | 2707   |
| MEDIÇÃO PESO E ALTURA        | 1545   |


## Registros posteriores à data de referência

| checagem                  | linhas |
| ------------------------- | ------ |
| cidadao_nascimento_futuro | 5      |
| atendimento_futuro        | 27     |
| procedimento_futuro       | 19     |


## Duplicidade por identificador entre transmissões

| tabela                 | linhas | ids_distintos | linhas_repetidas |
| ---------------------- | ------ | ------------- | ---------------- |
| atendimento_individual | 5545   | 3990          | 1555             |
| procedimentos          | 4252   | 3179          | 1073             |


## Cobertura dos campos de pressão

| afericoes | campo_documentado_preenchido | propriedades_preenchidas |
| --------- | ---------------------------- | ------------------------ |
| 2707      | 0                            | 2707                     |


## INEs com múltiplas grafias de nome de equipe

_Nenhuma linha retornada._

