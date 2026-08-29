# Mensagem para Engenharia de Dados

Oi, pessoal! Durante a modelagem da Lista Nominal de Hipertensão encontrei alguns pontos na origem que acho importante priorizarmos antes de considerar esse fluxo estável em produção.

**1. Registros retransmitidos gerando duplicidade lógica**  
Em `atendimento_individual`, temos 5.545 linhas para 3.990 identificadores distintos; em `procedimentos`, 4.252 linhas para 3.179 identificadores. Os mesmos registros aparecem novamente em transmissões posteriores. Para o case, tratei isso mantendo a versão da transmissão mais recente por identificador. O risco aqui é uma transformação consumir a camada bruta diretamente e contar o mesmo atendimento/procedimento mais de uma vez. Minha sugestão é formalizar essa chave e a regra de versionamento no contrato da origem ou em uma camada Silver compartilhada.

**2. Contrato do valor de pressão arterial não corresponde ao dado entregue**  
Nos 2.707 registros de `AFERIÇÃO DE PRESSÃO ARTERIAL`, o campo documentado `qt_afericao_pressao_arterial` está vazio em 100% dos casos, enquanto `propriedades` está preenchido em 100%. Para conseguir alimentar a lista, extraí `pressao_arterial` desse JSON. Funciona para o dataset atual, mas cria dependência de um campo diferente do documentado. Precisamos definir qual é a fonte oficial, atualizar o contrato/dicionário e incluir teste de completude para evitar quebra silenciosa.

**3. Datas incompatíveis com o snapshot**  
Há 27 atendimentos e 19 procedimentos posteriores a 01/08/2026, além de 5 datas de nascimento futuras. Para o snapshot, ignorei eventos clínicos posteriores à data de referência e sinalizei nascimento inválido sem excluir a pessoa. O impacto é relevante: eventos futuros podem alterar elegibilidade e status das boas práticas. Eu recomendaria uma validação automática de integridade temporal na ingestão, com alerta e quarentena dos registros incompatíveis.

Também encontrei 9 cidadãos elegíveis sem nome e variações de grafia de equipe em tabelas de eventos, mas priorizaria os três pontos acima pelo risco direto sobre contagem, elegibilidade e interpretação clínica dos indicadores.
