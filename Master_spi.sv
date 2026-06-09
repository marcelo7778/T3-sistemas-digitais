module Master_Spi (
    input  logic       clk,
    input  logic       reset,

    // --- Interface de Comando (Testbench) ---
    input  logic       start,    // TB avisa que quer iniciar uma leitura
    input  logic [1:0] reg_id,   // TB indica qual sensor (0 a 3) ler 
    output logic       ready,    // Master avisa o TB que está livre

    // --- Interface SPI (Multislave) ---
    output logic       sclk,     // Gerado pelo Master
    output logic       mosi,     // Master Out Slave In
    input  logic       miso,     // Master In Slave Out
    output logic [3:0] se,       // Seleção dos 4 Slaves (ativo em alto)

    // --- Interface da Memória (Scratchpad) ---
    output logic [7:0] ram_data_i, // Dado a ser escrito na memória
    output logic [7:0] ram_addr,   // Endereço de escrita
    output logic       ram_we      // Enable de escrita (Write Enable)
);

    // Definição dos estados da FSM
    typedef enum logic [2:0] {
        ST_IDLE,        // Aguardando comando do TB
        ST_SPI_LOW,     // SCLK em nível baixo (preparação/shift do Slave)
        ST_SPI_HIGH,    // SCLK em nível alto (captura do dado do MISO)
        ST_MEM_WRITE,   // Dispara o sinal de escrita na RAM
        ST_MEM_UPDATE   // Incrementa endereço para não sobrescrever dados
    } state_t;

    state_t state, next_state;

    // Registradores internos
    logic [7:0] shift_rx;      // Registrador de deslocamento para receber os bits
    logic [2:0] bit_cnt;       // Conta os 8 bits recebidos (0 a 7)
    logic [1:0] active_sensor; // Guarda qual sensor está sendo lido

    // Atualização de estado e registradores (Lógica Sequencial)
    always_ff @(posedge clk or negedge reset) begin
        if (!reset) begin // Assumindo reset ativo em baixo (ajuste se necessário)
            state      <= ST_IDLE;
            ram_addr   <= 8'd0;    // Inicia no endereço 0
            shift_rx   <= 8'd0;
            bit_cnt    <= 3'd0;
            active_sensor <= 2'b00;
        end else begin
            state <= next_state;

            // Operações que ocorrem nas transições de estado
            case (state)
                ST_IDLE: begin
                    if (start) begin
                        active_sensor <= reg_id; // Registra o pedido do TB
                        bit_cnt       <= 3'd0;
                    end
                end
                
                ST_SPI_HIGH: begin
                    // Captura o bit do MISO na borda de subida "simulada" do SCLK
                    shift_rx <= {shift_rx[6:0], miso};
                    bit_cnt  <= bit_cnt + 1'b1;
                end

                ST_MEM_UPDATE: begin
                    // Incrementa o endereço para a próxima escrita ser incremental
                    ram_addr <= ram_addr + 1'b1;
                end
            endcase
        end
    end

    // Lógica Combinacional (Próximo estado e saídas)
    always_comb begin
        // Valores padrão (evita latches)
        next_state = state;
        ready      = 1'b0;
        sclk       = 1'b0;
        mosi       = 1'b0; // Fixo em 0 pois o Mestre só lê do sensor neste projeto
        se         = 4'b0000;
        ram_we     = 1'b0;
        ram_data_i = shift_rx;

        case (state)
            ST_IDLE: begin
                ready = 1'b1; // Sinaliza ao TB que pode receber comando
                if (start) begin
                    next_state = ST_SPI_LOW;
                end
            end

            ST_SPI_LOW: begin
                se[active_sensor] = 1'b1; // Habilita apenas o sensor desejado
                sclk = 1'b0;              // SCLK desce
                next_state = ST_SPI_HIGH;
            end

            ST_SPI_HIGH: begin
                se[active_sensor] = 1'b1; // Mantém o slave habilitado
                sclk = 1'b1;              // SCLK sobe (onde o dado é capturado)
                
                if (bit_cnt == 3'd7) begin
                    next_state = ST_MEM_WRITE; // Se leu 8 bits, finaliza o SPI
                end else begin
                    next_state = ST_SPI_LOW;   // Volta para o próximo bit
                end
            end

            ST_MEM_WRITE: begin
                ram_we     = 1'b1; 
                next_state = ST_MEM_UPDATE;
            end

            ST_MEM_UPDATE: begin
                next_state = ST_IDLE;
            end

            default: next_state = ST_IDLE;
        endcase
    end

endmodule
