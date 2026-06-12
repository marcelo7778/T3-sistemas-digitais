module sensor #(
    parameter SENSOR_ID = 0,
    parameter REG_COUNT = 4,
    parameter REG_WIDTH = 8
)(
    input  logic clock, // Clock local (ex: 15 MHz, 25 MHz, 40 MHz ou 50 MHz)
    input  logic reset, // Reset do sistema (ativo em nível baixo)

    input  logic se,    // Slave Enable (vem do Master, ativo em alto)
    output logic miso,  // Saída de dados (Master In Slave Out)
    input  logic mosi,  // Entrada (não usada neste projeto, apenas leitura)
    input  logic sclk   // Clock do SPI (gerado e enviado pelo Master)
);

    // Array de registradores internos do sensor
    logic [REG_WIDTH-1:0] regs [REG_COUNT-1:0];
    
    // Registrador de deslocamento para a interface SPI
    logic [REG_WIDTH-1:0] shift_reg;
    
    // Ponteiro para saber qual registrador está sendo lido
    logic [$clog2(REG_COUNT)-1:0] reg_index;


    always_ff @(posedge clock or negedge reset) begin   
        if (!reset) begin
            for (int i = 0; i < REG_COUNT; i++) begin
                regs[i] <= $random(SENSOR_ID + i);
            end
        end else begin
            // Opcional: Você pode colocar uma lógica aqui para incrementar 
            // ou variar os valores de 'regs' ao longo do tempo para simular
            // um sensor dinâmico no Testbench.
        end
    end

    // --- 2. Controle de Endereçamento dos Registradores ---
    // Avança para o próximo registrador toda vez que o Master
    // encerra uma comunicação (quando a borda de descida de SE ocorre).
    always_ff @(negedge se or negedge reset) begin
        if (!reset) begin
            reg_index <= '0;
        end else begin
            // Incrementa circularmente: Volta a 0 se chegar no limite
            if (reg_index == REG_COUNT - 1)
                reg_index <= '0;
            else
                reg_index <= reg_index + 1'b1;
        end
    end

    // --- 3. Domínio do SPI (SCLK e SE) ---
    // Abordagem profissional para CDC: O sinal 'se' atua como um load assíncrono.
    always_ff @(negedge sclk or negedge se) begin
        if (!se) begin
            // Enquanto SE estiver baixo (desativado), o shift_reg fica engatilhado
            // com o valor do registrador atual. Isso garante que o primeiro bit
            // esteja pronto assim que o Master iniciar a leitura.
            shift_reg <= regs[reg_index];
        end else begin
            // Quando SE está alto, as bordas de descida do SCLK deslocam os bits.
            // O Master lê na borda de subida e o Slave muda o dado na borda de descida.
            shift_reg <= {shift_reg[REG_WIDTH-2:0], 1'b0};
        end
    end

    // --- 4. Saída MISO ---
    // Se o slave está habilitado, joga o bit mais significativo no pino MISO.
    // Caso contrário, joga 0 para não interferir nos outros sensores na linha.
    assign miso = se ? shift_reg[REG_WIDTH-1] : 1'b0;

endmodule
