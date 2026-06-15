# Coletor de Dados SPI com Múltiplos Domínios de Clock (CDC)

**Disciplina:** Sistemas Digitais  
**Professor:** Anderson Domingues  
**Ano/Semestre:** 2026/1  

## 👥 Equipe
* [Nome do Aluno 1]
* [Nome do Aluno 2]
* [Nome do Aluno 3]
* [Nome do Aluno 4 (se houver)]
* [Nome do Aluno 5 (se houver)]

---

## 💻 Apresentação do Projeto
Este projeto implementa um sistema de hardware em SystemVerilog focado na resolução de desafios de **Clock Domain Crossing (CDC)** e comunicação serial via protocolo **SPI**.

O sistema é composto por um **Coletor de Dados (Master)** operando a 100 MHz, que se comunica com **4 Emuladores de Sensor (Slaves)** operando em frequências distintas e assíncronas. Os dados coletados são gravados de forma sequencial em uma memória **Scratchpad RAM** ($2^8 \times 8$).

### Arquitetura de Clocks
* **Coletor de Dados (CD) / RAM:** 100 MHz
* **Emulador de Sensor 1:** 15 MHz
* **Emulador de Sensor 2:** 40 MHz
* **Emulador de Sensor 3:** 50 MHz
* **Emulador de Sensor 4:** 25 MHz

### Estrutura de Arquivos
* `Top.sv`: Módulo principal que unifica os componentes, distribui os domínios de clock e implementa o multiplexador de barramento MISO.
* `Master_Spi.sv`: Máquina de estados Síncrona do Coletor, responsável por gerar o SCLK seguro, ler os dados via SPI e gravar na RAM.
* `sensor.sv`: Emulador de sensor robusto com ponteiros indexados para transferências seguras entre domínios de clock diferentes.
* `scratchpad_ram.sv`: Memória RAM de 256 posições de 8 bits para armazenamento incremental.
* `tb_Top.sv`: Testbench automatizado (Self-Checking) que gera os estímulos e valida o funcionamento da RAM através de referências hierárquicas.

---

## 🚀 Instruções de Execução
O projeto foi desenvolvido e validado para ser executado no simulador **Questa / ModelSim**.

1. Clone este repositório para o seu ambiente local.
2. Abra o software de simulação (ModelSim/Questa).
3. Crie um novo projeto ou mude o diretório atual (`File > Change Directory`) para a pasta clonada.
4. Adicione todos os arquivos `.sv` ao projeto e compile-os (`Compile > Compile All`).
5. Inicie a simulação definindo o módulo `tb_Top.sv` como o *top-level* do teste (`Simulate > Start Simulation`).
6. Adicione os sinais desejados à aba *Waveform* para visualizar as transações SPI.
7. Execute a simulação completa (`Run -All`). O resultado do *Self-Checking* será impresso no terminal (*Transcript*).

---

## ✅ Resultados Obtidos
O sistema passou com sucesso em todos os testes automatizados, provando que não há perda de dados ou metainstabilidade (*glitches*) durante o cruzamento de domínios de clock ou na gravação em memória.

Abaixo está o registro de saída do console comprovando a leitura exata dos sensores e a gravação correta na RAM:

```text
==================================================
   INICIANDO TESTE DO COLETOR MULTI-CLOCK SPI
==================================================
--- Iniciando leitura do Sensor 0 (Sensor 1 - 15MHz) ---
[PASS] Sucesso! Valor lido do Sensor 0: bc. RAM expôs corretamente bc no pino data_o.
--------------------------------------------------
--- Iniciando leitura do Sensor 1 (Sensor 2 - 40MHz) ---
[PASS] Sucesso! Valor lido do Sensor 1: 41. RAM expôs corretamente 41 no pino data_o.
--------------------------------------------------
--- Iniciando leitura do Sensor 2 (Sensor 3 - 50MHz) ---
[PASS] Sucesso! Valor lido do Sensor 2: eb. RAM expôs corretamente eb no pino data_o.
--------------------------------------------------
--- Iniciando leitura do Sensor 3 (Sensor 4 - 25MHz) ---
[PASS] Sucesso! Valor lido do Sensor 3: 85. RAM expôs corretamente 85 no pino data_o.
--------------------------------------------------
--- Iniciando leitura do Sensor 0 (Sensor 1 - 15MHz (Leitura Registrador 2)) ---
[PASS] Sucesso! Valor lido do Sensor 0: 2a. RAM expôs corretamente 2a no pino data_o.
--------------------------------------------------

==================================================
RESULTADO FINAL: [PASS] - Todos os testes foram bem sucedidos!
==================================================
