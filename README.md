# Projeto Integrador — Business Intelligence
## FatecLog · Da origem transacional ao insight de negócio

**Curso:** Ciência de Dados — FATEC Jundiaí
**Desafio:** Business Intelligence · Data-to-Insight Journey
**Entrega:** junho/2026

---

### Dashboard online (Power BI)
🔗 https://app.powerbi.com/view?r=eyJrIjoiZDk5NzY4ZWMtNDgyZC00NDRlLThmYTUtZTExYjJhZTRjYjZiIiwidCI6ImVhYmU2NGM1LTY4ZjUtNGE3Ni04MzAxLTk1NzdhNjc5ZTQ0OSIsImMiOjR9

---

### Visão geral
O projeto analisa a operação de uma transportadora (FatecLog) a partir de **15.000 entregas**,
respondendo à pergunta central: **onde a operação está perdendo prazo e dinheiro — e o que fazer a respeito?**
O fluxo parte de um banco transacional, passa por modelagem dimensional e ETL, e chega a um dashboard de decisão.

### Arquitetura
Padrão **Power BI Only** com ETL em SQL:

> **MySQL (OLTP)** → **Star Schema** → **ETL (Stored Procedure)** → **Power BI**

- **Origem (OLTP):** banco MySQL `FatecLog`, com 7 tabelas transacionais normalizadas.
- **Modelagem:** Star Schema — **1 tabela fato** (`fato_entrega`, grão = 1 entrega) ligada a **7 dimensões**
  (cliente, centro, veículo, motorista, rota, tipo de carga e calendário), com **chaves substitutas (surrogate keys)**.
- **ETL:** stored procedure `sp_carga_full_dw` — trata nulos e inconsistências, padroniza nomes, classifica
  região e cria métricas derivadas (margem de frete, custo por km e horas de atraso), carregando o modelo analítico.
- **Análise:** Power BI Desktop — **17 medidas DAX** distribuídas em **3 páginas** (Visão Geral, Operacional, Financeiro).

### Estrutura dos arquivos
```
.
├── README.md                       este arquivo
├── Projeto_Integrador.pbix         dashboard completo (Power BI)
├── Diagrama_Dimensional.pdf        modelo dimensional (star schema)
└── sql/
    ├── 01-create_transacional.sql  banco e tabelas transacionais (OLTP)
    ├── 02-insert_dados.sql         carga de dados
    ├── 03-create_analitico.sql     star schema (dimensões + fato)
    ├── 04-procedure_etl.sql        stored procedure de carga (ETL) + execução
    └── medidas_dax.txt             as 17 medidas DAX do dashboard
```

### Como reproduzir (MySQL)
1. Execute os scripts em ordem: `01` → `02` → `03` → `04`.
   (o `04` cria a procedure e já executa `CALL sp_carga_full_dw()`).
2. Conecte o Power BI ao banco `FatecLog` e carregue as tabelas `fato_entrega` e `dim_*`.
3. O dashboard usa as medidas listadas em `sql/medidas_dax.txt`.

### Principais insights
- **OTD (pontualidade): 76,8%** — cerca de 23% das entregas fora do prazo.
- **Avaria: 25,5%** — taxa praticamente igual em todos os tipos de veículo, indicando que a causa
  está no **processo de manuseio/embalagem**, não na frota.
- **Custo por km inversamente proporcional à distância** — rotas curtas (Campinas, R$6,47/km)
  são proporcionalmente bem mais caras que as longas (Vitória, R$1,24/km).
- **Receita de R$39,1 mi** com **margem de R$29,3 mi (75%)**, distribuída de forma equilibrada entre os tipos de carga.

### Recomendações de negócio
1. Auditar o processo de embalagem/manuseio para reduzir a avaria (maior alavanca de qualidade).
2. Definir meta de OTD e priorizar a rota com pior pontualidade (Campinas).
3. Consolidar ou reprecificar as rotas curtas, onde o custo por km dispara.
4. Investigar os 5% de cancelamento e a fila de entregas "em trânsito".
