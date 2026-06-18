# Coletor de Dados SPI com Múltiplos Domínios de Clock (CDC)

**Disciplina:** Sistemas Digitais  
**Professor:** Anderson Domingues  
**Ano/Semestre:** 2026/1  

## Equipe
* Marcelo Vaz Barros
* Henzo Gradschi de Vasconcellos
* Eduardo Castilhos de Castilho
* Pedro Henrique Corral Livi

---

## Apresentação do Projeto
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
* `Master_spi.sv`: Máquina de estados Síncrona do Coletor, responsável por gerar o SCLK seguro, ler os dados via SPI e gravar na RAM.
* `Emulador_sensor.sv`: Emulador de sensor robusto com ponteiros indexados para transferências seguras entre domínios de clock diferentes.
* `Scratchped_ram_Test.sv`: Memória RAM de 256 posições de 8 bits para armazenamento incremental sem estados indefinidos.
* `tb_Top.sv`: Testbench automatizado (Self-Checking) que gera os estímulos e valida o funcionamento da RAM.
* `sim.do`: Script TCL para automação da compilação e execução da simulação.
---

## Instruções de Execução (via Script)
O projeto conta com um script de automação (`sim.do`) para facilitar a compilação e execução no simulador **Questa / ModelSim**, evitando configurações manuais.

1. Clone este repositório para o seu ambiente local.
2. Abra o software de simulação (ModelSim/Questa).
3. Mude o diretório atual do simulador para a pasta onde os arquivos foram clonados (`File > Change Directory`).
4. Na linha de comando do simulador (aba *Transcript*), execute o script digitando:
   ```tcl
   do sim.do
---

## Resultados Obtidos
O sistema passou com sucesso em todos os testes automatizados, provando que não há perda de dados ou metainstabilidade (*glitches*) durante o cruzamento de domínios de clock ou na gravação em memória.

Abaixo está o registro de saída do console comprovando a leitura exata dos sensores e a gravação correta na RAM:

```text
==================================================
   INICIANDO TESTE DO COLETOR MULTI-CLOCK SPI
==================================================
--- Iniciando leitura do Sensor 0 (Sensor 1 - 15MHz) ---
[PASS] Sucesso! Valor lido do Sensor 0: bc. RAM expos corretamente bc no pino data_o.
--------------------------------------------------
--- Iniciando leitura do Sensor 1 (Sensor 2 - 40MHz) ---
[PASS] Sucesso! Valor lido do Sensor 1: 41. RAM expos corretamente 41 no pino data_o.
--------------------------------------------------
--- Iniciando leitura do Sensor 2 (Sensor 3 - 50MHz) ---
[PASS] Sucesso! Valor lido do Sensor 2: eb. RAM expos corretamente eb no pino data_o.
--------------------------------------------------
--- Iniciando leitura do Sensor 3 (Sensor 4 - 25MHz) ---
[PASS] Sucesso! Valor lido do Sensor 3: 85. RAM expos corretamente 85 no pino data_o.
--------------------------------------------------
--- Iniciando leitura do Sensor 0 (Sensor 1 - 15MHz (Leitura Registrador 2)) ---
[PASS] Sucesso! Valor lido do Sensor 0: 2a. RAM expos corretamente 2a no pino data_o.
--------------------------------------------------

==================================================
RESULTADO FINAL: [PASS] - Todos os testes foram bem sucedidos!
==================================================
